def test_screen_two():
    for num in range(0, 100):
        col = int(num * 0.01 * 2.0)
        y = (num * 0.01 - float(col) / 2.0) * 2.0
        newY = y / 2.0 + 0.25
        print('col:' + str(float(col)) + ' num: ' + str(num) + ' y: ' + str(y) + ' newY: ' + str(newY))
        # print(str(newY))

def test_scale():
    for num in range(0, 100):
        col = num * 0.01
        textureCoordinateToUse = col - 0.5
        use = textureCoordinateToUse / 1.5
        newUse = use + 0.5
        print(' textureCoordinateToUse: ' + str(textureCoordinateToUse)[0:5] + ' use: ' + str(use)[0:5] + ' newUse: ' + str(newUse)[0:5] + ' ' + str(col / 1.5)[0:5])

if __name__ == "__main__":
    # test_scale()
    test_screen_two()
