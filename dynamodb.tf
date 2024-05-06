resource "aws_dynamodb_table" "gastebuch_tabelle" {
    name           = "gaestebuch-${var.env}"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "id"
    attribute {
        name = "id"
        type = "S"
    }
    
    tags = {
        Environment = var.env
    }
}
