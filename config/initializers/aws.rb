require 'aws-sdk-s3'

Aws.config.update(
  access_key_id: ENV["AWS_S3_KEY"] || "AKIAU57AY3DV3N2XVZUX",
  secret_access_key: ENV["AWS_S3_SECRET"] || "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",
  region: ENV["AWS_S3_REGION"] || "eu-west-1"
)
