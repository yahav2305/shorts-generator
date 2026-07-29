import boto3

client = boto3.client('bedrock-runtime')

response = client.converse(
    modelId="anthropic.claude-3-sonnet-20240229-v1:0",
    messages=[{"role": "user", "content": [{"text": "Hello, world!"}]}],
)
