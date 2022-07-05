# Docker & Kubernetes 

# Misc
## Git credentials cache
git config --global credential.helper cache

git config --global credential.helper "cache --timeout=3600d"    (in seconds)

# Design Principles
- Statless app 
- Small footprint 
- Observability 
- External configuration 
- Portability 
- Loose coupling

# State
RDS state (application state/data relational)
Spring boot embedded Web server (session state) - Redis (web session state) 
Dynamo DB (huge info with dynamic schema) - User behavior (/login /reward /checkout)
