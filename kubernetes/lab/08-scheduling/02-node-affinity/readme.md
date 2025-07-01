# Use Case - Node Affinity
Node affinity locks settlement processors to high-performance, settlement-labelled nodes in ap-south-1a, guaranteeing data-sovereignty compliance, consistent disk IOPS.
- Ref: 01-settlement-batch-processor.yaml

# Use Case - Running LLM workloads on GPU nodes
Latches AI inference pods to NVIDIA A100 GPU nodes within ap-south-1b, ensuring deterministic accelerator availability, single-AZ ultra-low latency, optimized utilization

- Ref 02-risk-ai-inference.yaml
- Ref https://brainupgrade.in/deepseek-on-kubernetes-ai-powered-reasoning-at-scale/

# Node Anti Affinity
Avoids HFT and spot nodes, maintaining latency and cost predictability.

Ref: 03-aml-realtime-gateway.yaml