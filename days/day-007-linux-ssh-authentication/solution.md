# SSH as root to stapp01
ssh tony@stapp01

# Method 1: Edit main sudoers file
visudo

# Add this line (make sure it's properly formatted):
tony    ALL=(ALL)       NOPASSWD:ALL
