kubectl  exec -it redis-0 -- sh
redis-cli 
auth password
info replication
SET class one
SET mount everest
KEYS *

k exec -it redis-1 -- sh
redis-cli
auth password
KEYS *