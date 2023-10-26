import random
def generate_password(size):
    chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    password = ''
    for i in range(size):
        password += random.choice(chars)
    return password
password = generate_password(8)
print(password)	