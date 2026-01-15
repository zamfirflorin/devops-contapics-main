# OCR Service

Python-based OCR (Optical Character Recognition) service that extracts text from images stored in S3.

## Features

- Reads images from AWS S3 or MinIO
- Uses Tesseract OCR for text extraction
- REST API with Flask
- Docker support
- Supports both AWS S3 and S3-compatible storage (MinIO)

## Technologies

- **Python 3.11**
- **Flask** - Web framework
- **Tesseract OCR** - Text recognition engine
- **boto3** - AWS SDK for Python
- **Pillow** - Image processing
- **pytesseract** - Python wrapper for Tesseract

## API Endpoints

### Health Check
```
GET /health
```

Returns service health status.

**Response:**
```json
{
  "status": "healthy",
  "service": "ocr-service"
}
```

### Perform OCR
```
POST /ocr
```

Extract text from an image stored in S3.

**Request Body:**
```json
{
  "s3_url": "https://bucket.s3.region.amazonaws.com/path/to/image.png"
}
```

or

```json
{
  "s3_key": "photos/company/image.png"
}
```

**Response (Success):**
```json
{
  "success": true,
  "text": "Extracted text from the image...",
  "s3_key": "photos/company/image.png"
}
```

**Response (Error):**
```json
{
  "success": false,
  "error": "Error message"
}
```

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `AWS_S3_BUCKET_NAME` | S3 bucket name | - | Yes |
| `AWS_REGION` | AWS region | `us-east-1` | No |
| `AWS_ACCESS_KEY_ID` | AWS access key | - | Yes |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | - | Yes |
| `AWS_S3_ENDPOINT` | S3 endpoint (for MinIO) | - | No |

## Running Locally

### Prerequisites

- Python 3.11+
- Tesseract OCR installed

**Install Tesseract:**

```bash
# macOS
brew install tesseract

# Ubuntu/Debian
sudo apt-get install tesseract-ocr

# Windows
# Download from: https://github.com/UB-Mannheim/tesseract/wiki
```

### Setup

0. **Virtual environment**
```bash
python3 -m venv venv
source venv/bin/activate
```

1. **Install dependencies:**
```bash
cd ocr-service
pip install -r requirements.txt
```

2. **Set environment variables:**
```bash
export AWS_S3_BUCKET_NAME=your-bucket-name
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
# Optional for MinIO:
# export AWS_S3_ENDPOINT=http://localhost:9000
```

3. **Run the service:**
```bash
python app.py
```

The service will start on `http://localhost:5001`

## Running with Docker

### Build the image:
```bash
docker build -t ocr-service .
```

### Run the container:
```bash
docker run -p 5001:5001 \
  -e AWS_S3_BUCKET_NAME=your-bucket-name \
  -e AWS_REGION=us-east-1 \
  -e AWS_ACCESS_KEY_ID=your-access-key \
  -e AWS_SECRET_ACCESS_KEY=your-secret-key \
  ocr-service
```

## Integration with Backend

The Spring Boot backend calls this service via the `/photos/{id}/ocr` endpoint:

1. User clicks "Extract Text" button in the UI
2. Frontend calls backend: `POST /photos/{id}/ocr`
3. Backend retrieves photo URL from database
4. Backend calls OCR service: `POST http://ocr-service:5001/ocr`
5. OCR service downloads image from S3 and extracts text
6. Text is returned to the frontend and displayed

## Testing

Test the OCR service with curl:

```bash
curl -X POST http://localhost:5001/ocr \
  -H "Content-Type: application/json" \
  -d '{
    "s3_url": "https://your-bucket.s3.amazonaws.com/photos/rich/image.png"
  }'
```

## Supported Image Formats

- PNG
- JPG/JPEG
- TIFF
- BMP
- GIF

## Notes

- OCR accuracy depends on image quality
- Best results with high-contrast, clear text
- Processing time depends on image size
- Tesseract supports multiple languages (English by default)
