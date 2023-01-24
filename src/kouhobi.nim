import std/times
import std/strutils

import cligen

const
  IOErrorMessage = "標準エラー出力に出力する際に何らかの問題が生じました"
  TimeParseErrorMessage = "日時時刻は YYYY-MM-dd-HH:mm の形式で入力する必要があります"
  ParseIntErrorMessage = "数値に変換できない値が入力されました"

template exitWithMessage (msg: string): untyped =
  try:
    stderr.writeLine("[Error]: " & msg)
  except IOError:
    echo ("[Error]: " & IOErrorMessage)
  return 1

func toJP (weekday: WeekDay): string =
  result = case weekday
           of dMon: "月"
           of dTue: "火"
           of dWed: "水"
           of dThu: "木"
           of dFri: "金"
           of dSat: "土"
           of dSun: "日"
  result = "(" & result & ")"

proc main (since, until, time: string, start = "00:00", stop = "24:00"): int {.raises: [].} =
  let
    since = try:
              since.parse("YYYY-MM-dd-HH:mm")
            except TimeParseError:
              exitWithMessage(TimeParseErrorMessage)
    until = try:
              until.parse("YYYY-MM-dd-HH:mm")
            except TimeParseError:
              exitWithMessage(TimeParseErrorMessage)
    time = try:
             initDuration(minutes = time.parseInt)
           except ValueError:
             exitWithMessage(ParseIntErrorMessage)
    start = try:
              start.parse("HH:mm")
            except TimeParseError:
              exitWithMessage(TimeParseErrorMessage)
    stop = try:
             stop.parse("HH:mm")
           except TimeParseError:
             exitWithMessage(TimeParseErrorMessage)
  block:
    var
      choseisanFormatSeq = newSeq[string]()
      datetime = since
    while true:
      if datetime + time > until:
        break
      let dataTimeOnlyHourAndMinute = try:
                                        datetime.format("HH:mm").parse("HH:mm")
                                      except TimeParseError:
                                        exitWithMessage(TimeParseErrorMessage)
      if (dataTimeOnlyHourAndMinute < start) or (dataTimeOnlyHourAndMinute + time > stop):
        datetime += time
        continue
      choseisanFormatSeq.add datetime.format("M/d") & datetime.weekday.toJP & " " & datetime.format("HH:mm")
      datetime += time
    
    echo choseisanFormatSeq.join("\n")

when isMainModule:
  dispatch(
    main,
    help = {
      "help": "ヘルプを表示します。",
      "since": "日程調整の開始日時です。YYYY-MM-dd-HH:mm 形式で入力してください。",
      "until": "日程調整の終了日時です。この時刻までに会議が終了する開始時刻を提示します。YYYY-MM-dd-HH:mm 形式で入力してください。",
      "time": "会議に確保する時間です。分単位で整数値で入力してください。",
      "start": "日程調整に用いる時間範囲の開始時刻です。HH:mm 形式で入力してください。",
      "stop": "日程調整に用いる時間範囲の終了時刻です。この時刻までに会議が終了する開始時刻を提示します。HH:mm 形式で入力してください。"
    }
  )
