import random
import strutils
import tables
import terminal
import os

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
    if 40000.0*(1/s.price) >= s.price.toFloat:
      increase += toInt(200.0*(1/s.price))
    else:
      increase -= toInt(s.price.toFloat/200.0)
    s.price += increase
    inc s.progress
  else:
    s.direction = sample([1, 1, 1, 1, -1, -1, -1])
    s.duration = rand(2 .. 10)
    s.progress = 0
    s.nextPrice()
  if s.price <= 0:
    s.price = 1

proc printStock(s: Stock) =
    echo s.name, " ".repeat(7 - len(s.name)), "█".repeat(s.price div 10), " $", s.price, " (", s.stocks, ") "

proc printMoney(p: Player) =
  echo "Your money: $", p.money

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
      if player.stocks.hasKey(stocc.name):
        if player.stocks[stocc.name] > 0:
          write(stdout, "how many (max?): ")
          amnt = readLine(stdin).toLowerAscii()
     
          if isNumber(amnt):
            sell(stocc, player, parseInt(amnt))
          elif amnt == "max":
            sell(stocc, player, stocc.stocks)
          else:
            echo "\"", amnt, "\" is not a number."
            promptUser()
        else:
          echo "You don't have any shares in that company!"
          promptUser()
      else:
          echo "You don't have any shares in that company!(2)"
          promptUser()
    elif choice == stocc2.name.toLowerAscii():
      if player.stocks.hasKey(stocc2.name):
        if player.stocks[stocc2.name] > 0:
          write(stdout, "how many (max?): ")
          amnt = readLine(stdin).toLowerAscii()
     
          if isNumber(amnt):
            sell(stocc2, player, parseInt(amnt))
          elif amnt == "max":
            sell(stocc2, player, stocc2.stocks)
          else:
            echo "\"", amnt, "\" is not a number."
            promptUser()
        else:
          echo "You don't have any shares in that company!"
          promptUser()
      else:
        echo "You don't have any shares in that company! (2)"
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
