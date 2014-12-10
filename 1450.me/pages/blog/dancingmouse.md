title: Dancing Mouse Mail Notification
draft: true
date: 2012-07-30
cover: instragram.jpg
---
Let’s see what we’re about to get first:

<iframe width="420" height="315" src="http://www.youtube.com/embed/uMMZ-8KGY1E" frameborder="0" allowfullscreen></iframe>

After reading Alex’ post on his [arduino hitcounter](http://tinkerlog.com/2007/12/04/arduino-xmas-hitcounter/), I decided that, since I get by far more emails than blog hits, it’d be more fun to have a physical email indicator. So, I got this plush mouse from IKEA and built a little disc mount to glue it onto a DC motor. I don’t have any [XBEE](http://www.arduino.cc/en/Main/ArduinoXbeeShield) or [Ethernet Shields](http://www.arduino.cc/en/Main/ArduinoEthernetShield), so my desktop computer has to do the dirty work of checking for new mails. Fortunately, this is incredibly easy in python:
import getpass, imaplib, serial, time
arduino = serial.Serial('/dev/ttyUSB0', 9600)
imap = imaplib.IMAP4('imap.googlemail.com')
imap.login(getpass.getuser(), getpass.getpass())
type, num = imap.select()
last_count = int(num[0])
while True:
    type, num = imap.select()
    # new_mail will be the number of new mails in the IMAP fodler
    new_mail = int(num[0]) - last_count
    if new_mail:
        arduino.write(chr(ord(chr(new_mail))))
    time.sleep(30)
On the Arduino, the code basically looks like this:

    void loop() {
      if (Serial.available() > 0) {
        // check for mails
        mails = Serial.read()
        // If we have mails, perform a dance!
        for (i = 0; i<mails; i++) {
            digitalWrite(13, HIGH);
            delay(1500); // Dance for 1500ms
            digitalWrite(13, LOW);
            delay(1000); // Rest and digest for 100ms
        }
      }
    }

You can download and fork a more robust and customisable version of the Python and Arduino source files on [Github](https://gist.github.com/1382962)!
