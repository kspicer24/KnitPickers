class Yarn:
    def __init__(self, brand, style, color):
        self.brand = brand
        self.style = style
        self.color = color

    def __str__(self):
        returnStr = ''

        returnStr = returnStr + self.brand + ' ' + self.style
        if self.color is not None:
            returnStr += ' in ' + self.color

        return returnStr


class Pattern:
    def __init__(self, pid, name, stitch, category, url, description, poster):
        self.name = name
        self.url = url
        self.category = category
        self.pid = pid
        self.stitch = stitch
        self.description = description
        self.poster = poster


class Comment:
    def __init__(self, user, comment, date):
        self.user = user
        self.comment = comment
        self.date = date
