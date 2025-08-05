#!/bin/bash

# === [Task 5] Create Service Account for Cloud Run ===
echo "📌 Creating service account: retrieval-identity..."
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create retrieval-identity || true
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:retrieval-identity@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"

# === [Task 6] Deploy Retrieval Service to Cloud Run ===
echo "🚀 Deploying Retrieval Service to Cloud Run..."
cd ~/genai-databases-retrieval-app
gcloud alpha run deploy retrieval-service \
    --source=./retrieval_service/ \
    --no-allow-unauthenticated \
    --service-account retrieval-identity@$PROJECT_ID.iam.gserviceaccount.com \
    --region=us-central1 \
    --network=default \
    --quiet

# === Verify service works ===
echo "🌐 Testing Retrieval Service endpoint..."
RETRIEVAL_URL=$(gcloud run services list --filter="retrieval-service" --format="value(URL)")
RESPONSE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-identity-token)" $RETRIEVAL_URL)
echo "✅ Retrieval Service response: $RESPONSE"

# === [Task 7] Deploy Sample App ===
echo "📦 Installing dependencies for sample app..."
cd ~/genai-databases-retrieval-app/llm_demo
source ~/genai-databases-retrieval-app/.venv/bin/activate
pip install -r requirements.txt

# === Set Environment Variables ===
export BASE_URL=$RETRIEVAL_URL
echo "✅ BASE_URL set to: $BASE_URL"

echo ""
echo "⚠️  Jangan lupa atur CLIENT_ID setelah membuatnya di Google Cloud Console!"
echo "📌 Contoh perintah setelah membuat OAuth Client ID:"
echo ""
echo "export CLIENT_ID=1234567890-abcxyz.apps.googleusercontent.com"
echo "python run_app.py"
echo ""
echo "🌐 Untuk akses via browser:"
echo "🔒 Jalankan di Cloud Shell (tab baru):"
echo "gcloud compute ssh instance-1 --zone=us-central1-f -- -L 8080:localhost:8081"
echo ""
echo "🌍 Lalu klik Web Preview > Preview on port 8080"
echo ""

