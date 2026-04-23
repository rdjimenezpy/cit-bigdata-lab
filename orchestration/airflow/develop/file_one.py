# Python file one module

# https://www.freecodecamp.org/espanol/news/python-if-name-main/

# Python module to execute

print("File one __name__ is set to: {}" .format(__name__))

if __name__ == "__main__":
    print("File one executed when ran directly")
else:
    print("File one executed when imported")