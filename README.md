# GenAI cloud project to privide context based LLM chat bot with RAG
#### infra scripts
infra/
├── variables.tf
├── main.tf
├── outputs.tf
├── backend.tf
└── modules/
    ├── iam/
    │   ├── variables.tf
    │   ├── user.tf
    │   ├── role.tf
    │   ├── policy.tf
    │   └── outputs.tf
    └── networking/
        ├── variables.tf
        ├── outputs.tf
        ├── nat.tf
        ├── route_table.tf
        ├── subnets.tf
        └── vpc.tf
### models
model/
├── gemma-3-4b
├── all-miniLM-L6-v2
### app scripts
app/
├── Dockerfile 
├── main.py
├── embedding_service.py
└── main.py
└── vector_store.py
└── llm_model.py
#### for k8s
k8s/
├── namespace.yaml           # Logical isolation boundary
├── configmap.yaml           # Non-secret config (env vars, config files)
├── secret.yaml              # Credentials, API keys (base64 or sealed)
├── deployment.yaml          # Your application workload
├── service.yaml             # Internal network endpoint (ClusterIP)
├── ingress.yaml             # External HTTP/HTTPS routing
├── hpa.yaml                 # HorizontalPodAutoscaler for autoscaling
└── pdb.yaml                 # PodDisruptionBudget for availability during
### run whole app
run.sh