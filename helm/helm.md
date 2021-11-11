git clone https://github.com/brainupgrade-in/helm-charts
cd helm-charts
git checkout -b gh-pages
helm create bu-nginx
touch bu-nginx/index.yaml
helm package bu-nginx
mv bu-nginx*.tgz bu-nginx/
cd ..
helm repo index helm-charts --url https://brainupgrade-in.github.io/helm-charts/
cd helm-charts
git add .
git commit -m "message" .
git push origin gh-pages

helm repo add bu-charts https://brainupgrade-in.github.io/helm-charts/
helm repo update
helm install bu-nginx bu-charts/bu-nginx

