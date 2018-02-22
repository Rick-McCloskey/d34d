import os, sys, string, time, getopt, socket, select, re

NoSuchDomain = "NoSuchDomain"

def whois(domainname, whoisserver=None, cache=0):
  if whoisserver is None:
    whoisserver = "whois.networksolutions.com"

  if cache:
    fn = "%s.dom" % domainname
    if os.path.exists(fn):
      return open(fn).read()

  page = _whois(domainname, whoisserver)

  if cache:
    open(fn, "w").write(page)

  return page

def _whois(domainname, whoisserver):
  s = None

  ## try until we are connected
  while s == None:
    try:
      s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
      s.setblocking(0)
      try:
        s.connect((whoisserver, 43))
      except socket.error, (ecode, reason):
        if ecode in (115, 150): pass
        else:
          raise socket.error, (ecode, reason)
      ret = select.select([s], [s], [], 30)

      if len(ret[1])== 0 and len(ret[0]) == 0:
        s.close()
        raise TimedOut, "on connect "
      s.setblocking(1)

    except socket.error, (ecode, reason):
      print ecode, reason
      time.sleep(10)
      s = None


  s.send("%s \n\n" % domainname)
  page = ""
  while 1:
    data = s.recv(8196)
    if not data: break
    page = page + data

  s.close()

  print page



whois("64.233.161.99", "whois.arin.net")