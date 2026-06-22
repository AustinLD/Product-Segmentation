# Power BI Guide: Product Segmentation Dashboard

Build this after the notebook runs, since it consumes two of its outputs.

## Inputs

1. `data/sku_clusters.csv` from the notebook: stock_code, cluster, segment_name.
2. The SKU feature table from `sql/01_sku_aggregation.sql` (or recompute in Power Query). Join on stock_code so every product row carries its segment and its features.

## Model

One flat table is enough: SKU grain, one row per stock_code, with segment_name, total_revenue, total_units, num_orders, num_customers, avg_unit_price, return_rate, seasonality, customer_concentration. Mark segment_name as the field you slice and color by everywhere.

## Page layout (single page, 1280 x 720)

Match the Project 1 house style so the portfolio reads as one body of work: dark background, single accent color, a top title band with a vertical accent bar, charts filling the canvas.

- **Title band (top):** "Product Segmentation" + subtitle "Clustering 4,000 SKUs by sales behavior, UK online retailer 2009 to 2011".
- **KPI row (4 cards):** total revenue, distinct SKUs, number of segments, overall return rate.
- **Hero, left (scatter):** avg_unit_price (x) vs num_orders (y, the velocity axis), bubble size = total_revenue, color = segment_name. This is the visual argument: segments occupy different price/velocity regions a ranking cannot see.
- **Top right (treemap):** revenue by segment_name. Shows which segments carry the business.
- **Bottom right (table or matrix):** one row per segment with n_skus, % of revenue, median price, median orders, median return rate. This is the profile a merchandiser reads.

## Recommendations panel

Add a short text box keyed to the segments, one action each (stock deeper, hold price premium, promote seasonally, investigate returns, prune the long tail). Fill the exact segment names and numbers from the notebook so nothing is generic.

## Notes

- Color segments consistently with the notebook's PCA scatter so the two artifacts agree.
- Keep the scatter axes on a log scale if the spread is extreme, matching the notebook's log transform.
- Do not leave any "Cluster 0" labels in the visuals. Everything should carry the plain-language segment name.
