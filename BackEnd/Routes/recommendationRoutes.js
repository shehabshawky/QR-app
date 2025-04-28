const express = require("express");
const router = express.Router();
const RecommendationService = require("../Services/recommendationService");
const { auth } = require("../Middlewares/auth");
const mongoose = require("mongoose");

// Get recommendations for a product
router.get("/:productId", auth, async (req, res) => {
  try {
    const { productId } = req.params;

    // Validate that productId is a valid MongoDB ObjectId
    if (!mongoose.Types.ObjectId.isValid(productId)) {
      return res.status(400).json({
        status: "error",
        message: "Invalid product ID format",
      });
    }

    const limit = parseInt(req.query.limit) || 3;

    const recommendations = await RecommendationService.getRecommendations(
      productId,
      req.user._id,
      limit
    );

    res.json({
      status: "success",
      data: recommendations,
    });
  } catch (error) {
    res.status(400).json({
      status: "error",
      message: error.message,
    });
  }
});

module.exports = router;
