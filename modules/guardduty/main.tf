resource "aws_guardduty_detector" "this" {
  enable = true
}

resource "aws_guardduty_threatintelset" "malware_scan" {
  count       = var.enable_malware_scan ? 1 : 0
  activate    = true
  detector_id = aws_guardduty_detector.this.id
  format      = "TXT"
  location    = var.malware_feed_url
  name        = "MalwareScan"
}
