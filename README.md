# What Kind of Product Is This? Clustering 4,000 SKUs by Sales Behavior

Most retailers manage products with a single lens: top sellers versus everything else. That hides the real structure of a catalog. A slow seller that one wholesale buyer reorders every month is a very different animal from a slow seller that moves only in December, even though a revenue ranking treats them the same.

This project takes a real online retailer's two years of transactions and lets the data group its products on its own, using k-means clustering on engineered sales features. The result is a small set of product segments, each with a clear merchandising meaning: what to keep in stock, what to watch, what to prune.

This is a portfolio project. The data is a real UK gift retailer's transaction log; the findings demonstrate method, not a live merchandising decision.

## The Questions

1. Beyond "bestseller vs. the rest," what natural product segments exist in the catalog when you account for velocity, price, seasonality, returns, and customer concentration?
2. How does data-driven clustering compare to a simple ABC/Pareto split, and what does it catch that Pareto misses?
3. What does each segment imply for inventory, pricing, and promotion?

## Stack

- **Python (Pandas, scikit-learn, Matplotlib):** clean the transaction log, engineer SKU-level features, scale them, run k-means with elbow and silhouette selection, profile and name the clusters
- **SQL (window functions, CTEs):** SKU aggregations, Pareto/ABC ranking, per-segment summaries
- **Power BI:** product segmentation dashboard (cluster scatter, revenue treemap, segment profile table)
- **GitHub:** version control

## Repo Structure

```
product-segmentation-analysis/
├── data/         # Raw data (gitignored, see Data below)
├── sql/          # SQL scripts, named by analysis
├── notebooks/    # Jupyter notebook for cleaning, features, and clustering
├── powerbi/      # .pbix dashboard
└── README.md
```

## Data

The dataset is not committed, to keep the repo light. Download "Online Retail II" and drop the file into `data/raw/` to reproduce the analysis: [Online Retail II (UCI, via Kaggle)](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci). It is roughly 1,067,000 rows, one per order line, spanning 01 Dec 2009 to 09 Dec 2011, with columns: Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer ID, Country.

## Key Findings

After cleaning, 4,479 products (with at least a little real sales history) carry roughly GBP 19.9M in revenue. K-means on the eight features lands on five segments, chosen with the elbow and silhouette:

- **Core bestsellers** (1,081 SKUs, 24% of the catalog) drive **78% of revenue**. High velocity, broad customer base, low price, low returns. The engine of the business.
- **Steady mid-volume** (1,607 SKUs, 36%) add another 14% of revenue. The reliable middle of the catalog.
- **Seasonal / wholesale-driven** (450 SKUs, 4% of revenue) have spiky monthly demand (seasonality CV 1.9) and lean heavily on a single buyer (top-customer share 0.42). Manage these by lead time, not by average.
- **Long-tail niche** (994 SKUs, 22% of the catalog, 2% of revenue) sell rarely, to few customers, at the highest prices. Prune candidates.
- **Returns-prone** (347 SKUs) show a **96% median return rate**. A clear quality or fit signal worth investigating regardless of revenue.

The payoff is the contrast with a plain ABC/Pareto split. Pareto holds (the top 23% of SKUs make 80% of revenue), but ABC class A is not just bestsellers: it hides 80 steady items, 38 seasonal/wholesale-dependent items, and **12 returns-prone products**. A flat revenue ranking says "protect class A" uniformly. The clustering shows that a dozen of those top-revenue products are bleeding returns and 38 depend on one seasonal buyer, three very different problems a ranking cannot see. Returns-prone and seasonal SKUs also span all three ABC classes, so neither issue can be managed by revenue tier at all.

## Method Notes

- Returns and cancellations (Invoice codes starting with `C`, negative quantities) are separated from sales and turned into a return-rate feature rather than dropped, since return behavior is itself a segment signal.
- Monetary and count features are heavily right-skewed, so they are log-transformed before standardizing, which keeps a handful of blockbuster SKUs from dominating the distance metric.
- Cluster count `k` is chosen from the elbow of within-cluster inertia together with the silhouette score, not by eye alone.
