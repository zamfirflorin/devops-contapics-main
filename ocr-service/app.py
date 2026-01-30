import os
import io
import boto3
from flask import Flask, request, jsonify
from PIL import Image
import pytesseract
import logging
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()
    
app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# AWS S3 Configuration
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')
AWS_REGION = os.getenv('AWS_REGION', 'eu-central-1')
S3_BUCKET_NAME = os.getenv('AWS_S3_BUCKET_NAME')
S3_ENDPOINT = os.getenv('AWS_S3_ENDPOINT', None)

# Initialize S3 client
if S3_ENDPOINT:
    # For MinIO
    s3_client = boto3.client(
        's3',
        endpoint_url=S3_ENDPOINT,
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION,
        config=boto3.session.Config(signature_version='s3v4')
    )
else:
    # For AWS S3
    s3_client = boto3.client(
        's3',
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
        region_name=AWS_REGION
    )

def extract_s3_key_from_url(url):
    """Extract S3 key from URL"""
    if S3_ENDPOINT and url.startswith(S3_ENDPOINT):
        # MinIO URL format: http://endpoint/bucket/key
        path = url.replace(S3_ENDPOINT + '/' + S3_BUCKET_NAME + '/', '')
        return path
    else:
        # AWS S3 URL format: https://bucket.s3.region.amazonaws.com/key
        from urllib.parse import urlparse
        parsed = urlparse(url)
        # Remove leading slash
        return parsed.path.lstrip('/')

def download_image_from_s3(s3_key):
    """Download image from S3"""
    try:
        logger.info(f"Downloading image from S3: bucket={S3_BUCKET_NAME}, key={s3_key}")
        response = s3_client.get_object(Bucket=S3_BUCKET_NAME, Key=s3_key)
        image_data = response['Body'].read()
        return Image.open(io.BytesIO(image_data))
    except Exception as e:
        logger.error(f"Error downloading image from S3: {str(e)}")
        raise

def perform_ocr(image):
    """Perform OCR on the image"""
    try:
        logger.info("Performing OCR on image")
        # Convert image to RGB if needed
        if image.mode != 'RGB':
            image = image.convert('RGB')

        # Perform OCR
        text = pytesseract.image_to_string(image)
        return text.strip()
    except Exception as e:
        logger.error(f"Error performing OCR: {str(e)}")
        raise

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'ocr-service'}), 200

@app.route('/ocr', methods=['POST'])
def ocr():
    """
    OCR endpoint that accepts either:
    - s3_url: Full S3 URL of the image
    - s3_key: S3 key of the image

    Returns extracted text from the image
    """
    try:
        data = request.get_json()

        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400

        # Get S3 key from URL or directly
        if 's3_url' in data:
            s3_url = data['s3_url']
            s3_key = extract_s3_key_from_url(s3_url)
            logger.info(f"Received S3 URL: {s3_url}, extracted key: {s3_key}")
        elif 's3_key' in data:
            s3_key = data['s3_key']
            logger.info(f"Received S3 key: {s3_key}")
        else:
            return jsonify({'error': 'Missing s3_url or s3_key parameter'}), 400

        # Download image from S3
        image = download_image_from_s3(s3_key)

        # Perform OCR
        extracted_text = perform_ocr(image)

        logger.info(f"OCR completed successfully. Extracted {len(extracted_text)} characters")

        return jsonify({
            'success': True,
            'text': extracted_text,
            's3_key': s3_key
        }), 200

    except Exception as e:
        logger.error(f"OCR processing failed: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    # Verify configuration
    if not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
        logger.error("AWS credentials not configured!")
    if not S3_BUCKET_NAME:
        logger.error("S3 bucket name not configured!")

    logger.info(f"Starting OCR service on port 5001")
    logger.info(f"S3 Bucket: {S3_BUCKET_NAME}")
    logger.info(f"S3 Endpoint: {S3_ENDPOINT if S3_ENDPOINT else 'AWS S3'}")

    app.run(host='0.0.0.0', port=5001, debug=True)
