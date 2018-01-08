#pylint: disable=C0301
import sys
from optparse import OptionParser
import urllib2
import re
from bs4 import BeautifulSoup
import webbrowser

def get_maya_flags(command):
    """
    Scrapes the Maya docs page for provided maya cmd and returns the flags.
    """
    request = urllib2.Request("http://help.autodesk.com/cloudhelp/2018/ENU/Maya-Tech-Docs/CommandsPython/" + command + ".html")
    try:
        html = urllib2.urlopen(request).read()
        soup = BeautifulSoup(html, 'html.parser')
        flags = []

        for tag in soup.find_all('a', {'name' : re.compile('flag*')}):
            first_b = tag.find_next('b')
            lname = first_b.text
            second_b = first_b.find_next('b')
            sname = second_b.text
            next_i = tag.find_next('i')
            arg_type = next_i.text
            if arg_type == "":
                arg_type += "None" #Certain mel commands are missing their argument types. Need to add something to add to the table to preserve the order
            flags.append((lname, sname, arg_type))

        for flag in flags:
            for item in flag:
                sys.stdout.write(str(item)+"\n")

    except urllib2.HTTPError:
        sys.exit("Not a valid maya command")

if __name__=='__main__':
    PARSER = OptionParser()
    PARSER.add_option("-c", "--command", dest="command", help="Maya command")
    PARSER.add_option("-v", "--version", dest="version", help="Maya Version")
    PARSER.add_option("-l", "--language", dest="language", help="Maya language")
    (OPTIONS, ARGS) = PARSER.parse_args()
    if OPTIONS.command:
        get_maya_flags(OPTIONS.command)
    else:
        sys.exit("No command given")
