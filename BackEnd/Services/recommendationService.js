const Product = require("../Models/Product");
const User = require("../Models/User");
const natural = require("natural");
const tokenizer = new natural.WordTokenizer();

class RecommendationService {
  static async getRecommendations(productId, userId, limit = 3) {
    try {
      const product = await Product.findById(productId);
      if (!product) {
        throw new Error("Product not found");
      }

      // Get user's scan history from the User model
      console.log("Fetching user scan history for userId:", userId);
      const user = await User.findById(userId).select("scanned_units");

      // Get all products that contain the scanned units
      const productsWithScannedUnits = await Product.find({
        "units._id": { $in: user.scanned_units },
      }).select("category name description properties");

      console.log("User Scanned Units Count:", user.scanned_units.length);
      console.log(
        "Products with Scanned Units:",
        productsWithScannedUnits.map((p) => ({
          productId: p._id,
          category: p.category,
          name: p.name,
        }))
      );

      const scannedProductIds = productsWithScannedUnits.map((p) =>
        p._id.toString()
      );

      // Get all products from the same company (admin)
      const companyProducts = await Product.find({ admin: product.admin })
        .where("_id")
        .ne(productId)
        .where("_id")
        .nin(scannedProductIds)
        .select("-units -__v"); // Exclude units and version key

      if (companyProducts.length === 0) {
        return [];
      }

      // Calculate recommendations
      const recommendations = await this.calculateRecommendations(
        product,
        companyProducts,
        productsWithScannedUnits,
        limit
      );

      // Format the recommendations
      return recommendations.map((product) => ({
        _id: product._id,
        name: product.name,
        description: product.description,
        category: product.category,
        price: parseFloat(product.price.toString()),
        properties: this.formatProperties(product.properties),
        image: product.image,
        release_date: product.release_date,
        warranty_duration: product.warranty_duration,
        scores: {
          similarity: product.similarityScore || 0,
          complementary: product.complementaryScore || 0,
          interest: product.interestScore || 0,
          combined: this.calculateCombinedScore(product),
        },
      }));
    } catch (error) {
      console.error("Error in getRecommendations:", error);
      throw error;
    }
  }

  static calculateCombinedScore(product) {
    const similarityScore = product.similarityScore || 0;
    const complementaryScore = product.complementaryScore || 0;
    const interestScore = product.interestScore || 0;

    return (
      similarityScore * 0.5 + complementaryScore * 0.3 + interestScore * 0.2
    );
  }

  static formatProperties(properties) {
    if (!properties) return {};

    const formattedProps = {};
    for (const [key, value] of properties.entries()) {
      formattedProps[key] = Array.isArray(value) ? value : [value];
    }
    return formattedProps;
  }

  static async calculateRecommendations(
    product,
    companyProducts,
    userHistory,
    limit
  ) {
    // 1. Similar Products (50% weight)
    const similarProducts = this.findSimilarProducts(product, companyProducts);

    // 2. Complementary Products (30% weight)
    const complementaryProducts = this.findComplementaryProducts(
      product,
      companyProducts
    );

    // 3. User Interest Products (20% weight)
    const userInterestProducts = this.findUserInterestProducts(
      product,
      companyProducts,
      userHistory
    );

    // Create a map to store all scores for each product
    const productScores = new Map();

    // Add similarity scores
    similarProducts.forEach((p) => {
      productScores.set(p._id.toString(), {
        ...p,
        similarityScore: p.similarityScore || 0,
        complementaryScore: 0,
        interestScore: 0,
      });
    });

    // Add complementary scores
    complementaryProducts.forEach((p) => {
      const existing = productScores.get(p._id.toString());
      if (existing) {
        existing.complementaryScore = p.complementaryScore || 0;
      } else {
        productScores.set(p._id.toString(), {
          ...p,
          similarityScore: 0,
          complementaryScore: p.complementaryScore || 0,
          interestScore: 0,
        });
      }
    });

    // Add interest scores
    userInterestProducts.forEach((p) => {
      const existing = productScores.get(p._id.toString());
      if (existing) {
        existing.interestScore = p.interestScore || 0;
      } else {
        productScores.set(p._id.toString(), {
          ...p,
          similarityScore: 0,
          complementaryScore: 0,
          interestScore: p.interestScore || 0,
        });
      }
    });

    // Convert map to array and sort by combined score
    const allRecommendations = Array.from(productScores.values())
      .map((p) => ({
        product: p,
        score: this.calculateCombinedScore(p),
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, limit)
      .map((rec) => rec.product);

    return allRecommendations;
  }

  static findSimilarProducts(product, companyProducts) {
    return companyProducts
      .map((otherProduct) => {
        // Description similarity using TF-IDF and cosine similarity
        const descriptionSimilarity = this.calculateDescriptionSimilarity(
          product.description,
          otherProduct.description
        );

        // Properties similarity using Jaccard
        const propertiesSimilarity = this.calculatePropertiesSimilarity(
          Array.from(product.properties.values()),
          Array.from(otherProduct.properties.values())
        );

        // Combined score
        const similarityScore =
          (descriptionSimilarity + propertiesSimilarity) / 2;

        return {
          ...otherProduct.toObject(),
          similarityScore,
        };
      })
      .filter((p) => p.similarityScore > 0.3)
      .sort((a, b) => b.similarityScore - a.similarityScore);
  }

  static findComplementaryProducts(product, companyProducts) {
    return companyProducts
      .map((otherProduct) => {
        let score = 0;

        // Check if product name appears in other product's description
        if (
          otherProduct.description
            .toLowerCase()
            .includes(product.name.toLowerCase())
        ) {
          score += 0.5;
        }

        // Check if product name appears in other product's properties
        const properties = Array.from(otherProduct.properties.values())
          .join(" ")
          .toLowerCase();
        if (properties.includes(product.name.toLowerCase())) {
          score += 0.5;
        }

        return {
          ...otherProduct.toObject(),
          complementaryScore: score,
        };
      })
      .filter((p) => p.complementaryScore > 0)
      .sort((a, b) => b.complementaryScore - a.complementaryScore);
  }

  static findUserInterestProducts(product, companyProducts, userHistory) {
    // Count category occurrences in user history
    const categoryCounts = {};
    userHistory.forEach((history) => {
      const category = history.category;
      categoryCounts[category] = (categoryCounts[category] || 0) + 1;
    });

    console.log("Category Counts:", categoryCounts);
    console.log(
      "Max Category Count:",
      Math.max(...Object.values(categoryCounts))
    );

    return companyProducts
      .map((otherProduct) => {
        const categoryScore = categoryCounts[otherProduct.category] || 0;
        const maxCategoryCount = Math.max(...Object.values(categoryCounts));
        const normalizedScore =
          maxCategoryCount > 0 ? categoryScore / maxCategoryCount : 0;

        console.log(
          `Product ${otherProduct.name} (${otherProduct.category}):`,
          {
            categoryScore,
            maxCategoryCount,
            normalizedScore,
          }
        );

        return {
          ...otherProduct.toObject(),
          interestScore: normalizedScore,
        };
      })
      .filter((p) => p.interestScore > 0)
      .sort((a, b) => b.interestScore - a.interestScore);
  }

  static calculateDescriptionSimilarity(desc1, desc2) {
    const tokens1 = tokenizer.tokenize(desc1.toLowerCase());
    const tokens2 = tokenizer.tokenize(desc2.toLowerCase());

    const tfidf = new natural.TfIdf();
    tfidf.addDocument(tokens1);
    tfidf.addDocument(tokens2);

    const vector1 = new Array(tokens2.length).fill(0);
    const vector2 = new Array(tokens2.length).fill(0);

    tfidf.tfidfs(tokens1, function (i, measure) {
      vector1[i] = measure;
    });

    tfidf.tfidfs(tokens2, function (i, measure) {
      vector2[i] = measure;
    });

    return this.cosineSimilarity(vector1, vector2);
  }

  static calculatePropertiesSimilarity(props1, props2) {
    const set1 = new Set(props1);
    const set2 = new Set(props2);

    const intersection = new Set([...set1].filter((x) => set2.has(x)));
    const union = new Set([...set1, ...set2]);

    return intersection.size / union.size;
  }

  static cosineSimilarity(vec1, vec2) {
    const dotProduct = vec1.reduce((acc, val, i) => acc + val * vec2[i], 0);
    const norm1 = Math.sqrt(vec1.reduce((acc, val) => acc + val * val, 0));
    const norm2 = Math.sqrt(vec2.reduce((acc, val) => acc + val * val, 0));

    if (norm1 === 0 || norm2 === 0) return 0;
    return dotProduct / (norm1 * norm2);
  }
}

module.exports = RecommendationService;
