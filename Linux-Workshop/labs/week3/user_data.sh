#!/bin/bash
yum update -y
yum install -y nginx

cat <<'EOF' > /usr/share/nginx/html/index.html
${html_content}
EOF

systemctl enable nginx
systemctl start nginx
