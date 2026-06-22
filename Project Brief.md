# Project 4: Product Segmentation (SKU Clustering)

## One-line

Use unsupervised clustering to group a real retailer's ~4,000 products into merchandising segments based on how they actually sell, then translate each segment into an inventory and pricing recommendation.

## Why this project

The other three portfolio projects cover SQL window functions (Spotify), a full e-commerce build (Olist), and statistical experimentation (marketing A/B). All three are customer- or transaction-centric and use supervised or inferential methods. This one is deliberately different on two axes:

- **Unit of analysis:** the product, not the customer or the order. It answers "what kind of thing is this" instead of "who bought" or "did the treatment work."
- **Method:** unsupervised learning. There is no label to predict. The model finds structure and the analyst interprets it. That is a distinct skill from hypothesis testing.

It also pairs with the RFM work on the skills tracker: same standardize-then-segment muscle, applied to products instead of customers.

## The question

When you describe each SKU by its real sales behavior (velocity, price point, seasonality, return rate, customer concentration) and let k-means group them, what segments emerge, and what should a merchandiser do differently for each one?

## Dataset

Online Retail II (UCI Machine Learning Repository, mirrored on Kaggle). A UK-based online gift retailer, all transactions 01 Dec 2009 to 09 Dec 2011. ~1,067,000 order lines, ~5,000 distinct stock codes. Columns: Invoice, StockCode, Description, Quantity, InvoiceDate, Price, Customer ID, Country. Real, messy, and well-suited to feature engineering (it includes returns, wholesale-size orders, and strong December seasonality).

## SKU-level features

Built by aggregating order lines up to one row per StockCode:

1. total_revenue: sum of Quantity x Price on sales lines
2. total_units: units sold
3. num_orders: distinct invoices the SKU appears on (velocity)
4. num_customers: distinct customers who bought it (reach)
5. avg_unit_price: revenue per unit
6. return_rate: returned units / sold units
7. seasonality: coefficient of variation of monthly units across active months
8. customer_concentration: revenue share of the SKU's single largest customer (wholesale dependence)

## Method

Clean -> aggregate to SKU -> log-transform skewed monetary/count features -> standardize -> k-means. Pick k from elbow of inertia plus silhouette. Profile clusters on the original (un-scaled) feature means and name them. Run PCA to a 2D scatter for the visual. Benchmark against a plain ABC/Pareto revenue split to show what clustering adds.

## Deliverables

- Python notebook: cleaning, feature engineering, k selection, clustering, cluster profiles, charts
- SQL scripts: SKU aggregation, Pareto/ABC ranking with window functions, per-segment rollups
- Power BI dashboard: cluster scatter, revenue-by-segment treemap, segment profile table, KPI cards
- Case study: problem, approach, segments found, merchandising recommendations
- README and this brief

## Status

Scaffolded. Notebook, SQL, README, and brief drafted. Pending: Austin downloads the dataset and creates the GitHub repo, then the notebook runs end to end and the case study + Key Findings are filled from real outputs.
