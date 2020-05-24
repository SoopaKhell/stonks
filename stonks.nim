import random
import strutils
import tables
import terminal

randomize()

type
  Stock = object
    name: string
    price: int
    stocks: int
    direction: int
    duration: int
    progress: int
  
  Player = object
    money: int
    stocks: Table[string, int]

proc nextPrice(s: var Stock) =
  var increase: int
  if s.progress < s.duration: 
    if rand(1 .. 4) == 1:
      increase = s.direction*rand(2 .. 12)
    else:
      increase = s.direction*rand(1 .. 6)
    s.price += increase
    inc s.progress
  else:
    s.direction = sample([1, -1])
    s.duration = rand(2 .. 5)
    s.progress = 0
    s.nextPrice()

proc printStock(s: Stock) =
  echo s.name, ": $", s.price, " (", s.stocks, ")"

proc printMoney(p: Player) =
  echo "your money: $", p.money

proc buy(s: var Stock, p: var Player, amount: int) =
  s.stocks += amount
  p.money -= s.price*amount
  s.price += s.price div amount
  if p.stocks.hasKey(s.name):
    p.stocks[s.name] += amount
  else:
    p.stocks[s.name] = amount

proc sell(s: var Stock, p: var Player, amount: int) =
  s.stocks -= amount
  p.money += s.price*amount
  p.stocks[s.name] -= amount
  s.price -= s.price div amount

proc isNumber(s: string): bool =
  for ch in s:
    if not isDigit(ch):
      return false
  return true

var stocc = Stock(name: "NASDAQ", price: 200)
var stocc2 = Stock(name: "AAPL", price: 200)

var player = Player(money: 2000)

var choice: string
var amnt: string



proc promptUser() =
  player.printMoney()
  
  echo()

  stocc.printStock()
  stocc2.printStock()
 
  echo()
  
  write(stdout, "buy or sell?: ")
  choice = readLine(stdin).toLowerAscii()

  if choice == "buy":
    write(stdout, "which stock to buy: ")
    choice = readLine(stdin).toLowerAscii()

    if choice == stocc.name.toLowerAscii():
      write(stdout, "how many (max?): ")
      amnt = readLine(stdin).toLowerAscii()
 
      if isNumber(amnt):
        buy(stocc, player, parseInt(amnt))
      elif amnt == "max":
        buy(stocc, player, player.money div stocc.price)
      else:
        echo "\"", amnt, "\" is not a number."
        promptUser()

    elif choice == stocc2.name.toLowerAscii():
      write(stdout, "how many (max?): ")
      amnt = readLine(stdin).toLowerAscii()
 
      if isNumber(amnt):
        buy(stocc2, player, parseInt(amnt))
      elif amnt == "max":
        buy(stocc2, player, player.money div stocc2.price)
      else:
        echo "\"", amnt, "\" is not a number."
        promptUser()
    else:
      echo "\"", choice, "\" is not a stock."
      promptUser()
  elif choice == "sell":
    write(stdout, "which stock to sell: ")
    choice = readLine(stdin).toLowerAscii()

    if choice == stocc.name.toLowerAscii():
      write(stdout, "how many (all?): ")
      amnt = readLine(stdin).toLowerAscii()
 
      if isNumber(amnt):
        sell(stocc, player, parseInt(amnt))
      elif amnt == "all":
        sell(stocc, player, stocc.stocks)
      else:
        echo "\"", amnt, "\" is not a number."
        promptUser()

    elif choice == stocc2.name.toLowerAscii():
      write(stdout, "how many (all?): ")
      amnt = readLine(stdin).toLowerAscii()
 
      if isNumber(amnt):
        sell(stocc2, player, parseInt(amnt))
      elif amnt == "all":
        sell(stocc2, player, stocc2.stocks)
      else:
        echo "\"", amnt, "\" is not a number."
        promptUser()
    else:
      echo "\"", choice, "\" is not a stock."
      promptUser()
while true: 
  eraseScreen()

  promptUser()

  if player.money < 0:
    write(stdout, "You went bankrupt! better luck next time.")
    break

  stocc.nextPrice()
  stocc2.nextPrice()
