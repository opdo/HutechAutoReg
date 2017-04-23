#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Res_Comment=AUTOREGHUTECH
#AutoIt3Wrapper_Res_Description=AUTOREGHUTECH
#AutoIt3Wrapper_Res_Fileversion=1.0
#AutoIt3Wrapper_Res_LegalCopyright=AUTOREGHUTECH
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#EndRegion

#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiButton.au3>
#include <EditConstants.au3>
#include <Scripts/_HttpRequest.au3>
#include <File.au3>

Global $_COOOKIE, $_COOOKIE2, $__VIEWSTATE, $_FILE = 0, $MAX_TIMES = 40
Global $_SLEEP = 0, $_VER = "0.1"
Global $LoginGUI = GUICreate("HUTECH AUTO REG", 562, 305, -1, -1, -1, -1)
GUISetIcon(@ScriptDir & "\icon.ico")
GUISetBkColor(0x595959, $LoginGUI)
Global $acclb = GUICtrlCreateLabel("Account:", 20, 15, 52, 20, $SS_CENTERIMAGE, -1)
GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "-2")
Global $acc = GUICtrlCreateInput("", 75, 15, 150, 20, -1, $WS_EX_CLIENTEDGE)
GUICtrlSetBkColor(-1, "0x595959")
GUICtrlSetColor(-1, "0xFFFFFF")
Global $passlb = GUICtrlCreateLabel("Password:", 238, 15, 55, 20, $SS_CENTERIMAGE, -1)
GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "-2")
Global $pass = GUICtrlCreateInput("", 295, 15, 150, 20, $ES_PASSWORD, $WS_EX_CLIENTEDGE)
GUICtrlSetBkColor(-1, "0x595959")
GUICtrlSetColor(-1, "0xFFFFFF")
Global $login = GUICtrlCreateLabel("LOGIN", 460, 15, 77, 20, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
GUICtrlSetColor(-1, "0x595959")
GUICtrlSetFont(-1, 10, 600, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, "0xFFFFFF")
GUICtrlSetCursor(-1, 0)
Global $command = GUICtrlCreateInput("command here", 20, 267, 430, 24, -1, $WS_EX_CLIENTEDGE)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "0x595959")
Global $cmdbtn = GUICtrlCreateLabel("GỬI CMD", 460, 267, 80, 24, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
GUICtrlSetColor(-1, "0x595959")
GUICtrlSetBkColor(-1, "0xFFFFFF")
GUICtrlSetFont(-1, 10, 600, 0, "MS Sans Serif")
GUICtrlSetCursor(-1, 0)

Global $edittxt = GUICtrlCreateEdit("", 20, 55, 521, 202, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL), -1)
GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "0x595959")
GUISetState(@SW_SHOW, $LoginGUI)

_DisableInput()
_DisableInput(3)

if not _Captcha() then
	GUICtrlSetData($login, "CAPTCHA")
EndIf
_Text("- Version: "&$_VER)
_Text("- Contact info: hi@opdo.vn")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $login
			GUICtrlSetState($login, $GUI_DISABLE)

			if GUICtrlRead($login) = "LOGIN" Then
				if (GUICtrlRead($acc) = "file") Then
					$_FILE = 1
					$f = FileOpenDialog("Chon file","","Text (*.txt)")
					if not @error Then
						$line = _FileCountLines($f)
						for $i = 1 to $line
							$data = StringSplit(FileReadLine($f, $i), "|")
							if $data[0] >= 3 Then
								if ($data[0] >= 4) Then
									_Text("[FILE] Bỏ qua MSSV " & $data[1] & " (đã đăng ký)")
								Else
									if ($data[2] <> "") Then
										GUICtrlSetData($acc,$data[1])
										GUICtrlSetData($pass,$data[2])
										if _Login() Then
											;ContinueLoop ;TEST
											_Text("[FILE] Thực hiện lệnh đăng ký với MSSV " & $data[1])
											$mon = StringSplit($data[3], ",")
											$txt = ""
											For $j = 1 to $mon[0]
												$reg = StringSplit($mon[$j],"@")
												if $reg[0] < 2 Then ContinueLoop
												if (_Reg($reg[1], $reg[2])) Then $txt = $mon[$j]&","
											Next
											if $txt <> "" then _FileWriteToLine($f, $i, FileReadLine($f, $i)&"|"&$txt)
											_Logout()
										Else

											_Text("[FILE] Bỏ qua MSSV " & $data[1] & " (something went wrong)")
											;ExitLoop
										EndIf
									Else
										_Text("[FILE] Bỏ qua MSSV " & $data[1] & " (nopass)")
									EndIf
								EndIf
							Else
								_Text("[FILE] Bỏ qua MSSV " & $data[1] & " (thiếu dữ kiện)")
							EndIf
						Next
					EndIf
				else
					_Login()
				EndIf
			Elseif GUICtrlRead($login) = "CAPTCHA" Then
				if not _Captcha() then
					GUICtrlSetData($login, "CAPTCHA")
				EndIf
			Else
				_Logout()
			EndIf
			$_FILE = 0
			GUICtrlSetState($login, $GUI_ENABLE)
		Case $GUI_EVENT_CLOSE
			Exit
		Case $cmdbtn
			$cmd = StringSplit(GUICtrlRead($command), '@')
			If ($cmd[0] > 1) Then
				If ($cmd[1] = "list") Then
					_Text("[LIST] Đang lấy list vui lòng đợi")
					_List($cmd[2])
					_Text("[LIST] Lấy list thành công")
				ElseIf ($cmd[1] = "reg") Then
					If ($cmd[0] > 2) Then
						_Reg($cmd[2], $cmd[3])
					Else
						_Text("[CMD] Lệnh không đầy đủ (cấu trúc lệnh reg@<mã mh>@<nhóm mh>)")
					EndIf
				EndIf
			Else
				_Text("[CMD] Lệnh không chính xác")
			EndIf

	EndSwitch
WEnd

Func _Text($txt)
	GUICtrlSetData($edittxt, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $txt & @CRLF, 1)
	if $_FILE = 1 then _FileWriteLog(@ScriptDir&"\auto_log.txt",$txt)
EndFunc   ;==>_Text

Func _Captcha($times = 0)
	if $_SLEEP > 0 then Sleep($_SLEEP)
	_Text("[CAPTCHA] Đang lấy captcha và cookie")
	$http = _HttpRequest(4, "http://daotao.hutech.edu.vn/")
	if @error Then
		_Text("[CAPTCHA] Không lấy được nội dung trang daotao.hutech.edu.vn")
		Return False
	EndIf
	$captcha = StringRegExp(StringReplace($http[1], @CRLF, ""), 'size="6">(.*?)<', 3)
	if ($http[1] = "The service is unavailable.") Then
		_Text("[CAPTCHA] Trang daotao.hutech.edu.vn hiện không còn hoạt động")
		Return False
	Elseif ($http[1] = "") Then
		_Text("[CAPTCHA] Không nhận được phản hồi từ daotao.hutech.edu.vn")
		Return False
	EndIf
	if StringInStr($http[1],'ctl00_ContentPlaceHolder1_ctl00_lblCapcha') == 0 and StringInStr($http[1], "ctl00$ContentPlaceHolder1$ctl00$ucDangNhap$btnDangNhap") > 0 Then
		$_COOOKIE = _GetCookie($http[0])
		_Text("[CAPTCHA] Không có captcha để vượt")
		_DisableInput(1)
		Return True
	EndIf
	If UBound($captcha) > 0 Then
		$_COOOKIE = _GetCookie($http[0])
		$__VIEWSTATE = StringRegExp(StringReplace($http[1], @CRLF, ""), 'name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)"', 3)[0]
		_Text("[CAPTCHA] Đã tách được captcha " & $captcha[0])
		$post = '------WebKitFormBoundaryfxbNij4sZMoKTt0r' & @CRLF & _
				'Content-Disposition: form-data; name="__EVENTTARGET"' & @CRLF & _
				'' & @CRLF & _
				'' & @CRLF & _
				'------WebKitFormBoundaryfxbNij4sZMoKTt0r' & @CRLF & _
				'Content-Disposition: form-data; name="__EVENTARGUMENT"' & @CRLF & _
				'' & @CRLF & _
				'' & @CRLF & _
				'------WebKitFormBoundaryfxbNij4sZMoKTt0r' & @CRLF & _
				'Content-Disposition: form-data; name="__VIEWSTATE"' & @CRLF & _
				'' & @CRLF & _
				$__VIEWSTATE & @CRLF & _
				'------WebKitFormBoundaryfxbNij4sZMoKTt0r' & @CRLF & _
				'Content-Disposition: form-data; name="ctl00$ContentPlaceHolder1$ctl00$txtCaptcha"' & @CRLF & _
				'' & @CRLF & _
				$captcha[0] & @CRLF & _
				'------WebKitFormBoundaryfxbNij4sZMoKTt0r' & @CRLF & _
				'Content-Disposition: form-data; name="ctl00$ContentPlaceHolder1$ctl00$btnXacNhan"' & @CRLF & _
				'' & @CRLF & _
				'Vào website' & @CRLF & _
				'------WebKitFormBoundaryfxbNij4sZMoKTt0r--'
		_Text("[CAPTCHA] Đang vượt captcha")
		$http = _HttpRequest(4, "http://daotao.hutech.edu.vn/default.aspx", $post, $_COOOKIE, 'http://daotao.hutech.edu.vn/', 'Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryfxbNij4sZMoKTt0r')
		If (StringInStr($http[1], "ctl00$ContentPlaceHolder1$ctl00$ucDangNhap$btnDangNhap") > 0) Then
			$__VIEWSTATE = StringRegExp(StringReplace($http[1], @CRLF, ""), 'name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)"', 3)[0]
			$_COOOKIE = _GetCookie($http[0])
			GUICtrlSetData($edittxt, '')
			_Text("[CAPTCHA] Vượt captcha thành công")
			_Text("[CAPTCHA] MỜI BẠN TIẾN HÀNH ĐĂNG NHẬP")
			_DisableInput(1)
			Return True
		Else
			_Text("[CAPTCHA] Vượt captcha thất bại")
		EndIf
	Else
		If ($times >= 5) Then
			_Text("[CAPTCHA] Tách captcha thất bại, ngưng tiến trình")
		Else
			_Text("[CAPTCHA] Tách captcha thất bại, đang thực hiện lại lần " & $times + 1 & "/5")
			Return _Captcha($times + 1)
		EndIf
	EndIf
	Return False
EndFunc   ;==>_Captcha

Func _Find($find_what)
	$find_what = StringUpper($find_what)
	$post = '{"dkLoc":"' & $find_what & '"}'
	$http = _HttpRequest(4, "http://daotao.hutech.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", $post, $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method:LocTheoMonHoc')
	if @error Then
		_Text("[LIST] Không lấy được nội dung trang daotao.hutech.edu.vn")
		Return False
	EndIf
	Return $http[1]
EndFunc   ;==>_Find

Func _List($m)
	$m = StringUpper($m)
	$mh = _Find($m)
	$mh = StringTrimRight($mh, 2)
	$mh = StringTrimLeft($mh, 10)
	FileDelete(@TempDir & '\regmh.html')
	FileWrite(@TempDir & '\regmh.html', $mh)
	ShellExecute(@TempDir & '\regmh.html')
EndFunc   ;==>_List


Func _Logout()
	Sleep($_SLEEP)
	_Text("[LOGOUT] Đang logout và lấy lại captcha")
	$post = '------WebKitFormBoundaryntueNUAAVSpHBYGo' & @CRLF & _
	'Content-Disposition: form-data; name="__EVENTTARGET"' & @CRLF & _
	'' & @CRLF & _
	'ctl00$Header1$ucLogout$lbtnLogOut' & @CRLF & _
	'------WebKitFormBoundaryntueNUAAVSpHBYGo' & @CRLF & _
	'Content-Disposition: form-data; name="__EVENTARGUMENT"' & @CRLF & _
	'' & @CRLF & _
	'' & @CRLF & _
	'------WebKitFormBoundaryntueNUAAVSpHBYGo' & @CRLF & _
	'Content-Disposition: form-data; name="__VIEWSTATE"' & @CRLF & _
	'' & @CRLF & _
	$__VIEWSTATE & @CRLF & _
	'' & @CRLF & _
	'------WebKitFormBoundaryntueNUAAVSpHBYGo--'
	$http = _HttpRequest(4, "http://daotao.hutech.edu.vn/default.aspx", $post, $_COOOKIE, 'http://daotao.hutech.edu.vn/', 'Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryntueNUAAVSpHBYGo')
	if @error Then
		_Text("[LOGOUT] Không lấy được nội dung trang daotao.hutech.edu.vn")
		Return False
	EndIf
	if _Captcha() then
		_Text("[LOGOUT] Đã logout thành công, mời login lại")
		GUICtrlSetData($acc,'')
		GUICtrlSetData($pass,'')
		WinSetTitle($LoginGUI,"","HUTECH AUTO REG")
	Else
		_Text("[LOGOUT] Logout thất bại, hãy tắt và mở lại chương trình")
	EndIf
EndFunc

Func _Reg($m, $id)
	Sleep($_SLEEP)
	$m = StringUpper($m)
	_Text("[REG] Đang tiến hành đăng ký môn " & $m & '-' & $id)

	$http = _HttpRequest(4, "http://daotao.hutech.edu.vn/Default.aspx?page=dkmonhoc", '', $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx')
	if @error Then
		_Text("[REG] Không lấy được nội dung trang daotao.hutech.edu.vn")
		Return False
	EndIf
	$_COOOKIE = _GetCookie($http[0])
	If (StringInStr($http[1], "ctl00_ContentPlaceHolder1_ctl00_lblCapcha") > 0) Then
		_Text("[REG] Phiên đăng nhập hết hạn, đang lấy lại captcha và đăng nhập lại")
		If (_Captcha()) Then
			If (_Login()) Then
				_Reg($m, $id)
			Else
				_Text("[REG] Đăng nhập thất bại, hãy tắt chương trình và mở lại")
			EndIf
		EndIf
	Else
		$mh = _Find($m)
		If StringInStr($mh, $m) > 0 And StringInStr($mh, $id) > 0 Then
			$pat = "id='chk_" & $m & "   " & $id & "'" & '  \\r\\nvalue=\\"(.*?)\\"'
			$db = StringRegExp($mh, $pat, 3)
			If (UBound($db) > 0) Then
				_Text("[REG] Đang tiến hành gửi lệnh đăng ký")
				$split_db = StringSplit($db[0], '|')
				If $split_db[0] >= 13 Then
					$post = '{"check":true,"maDK":"' & $split_db[1] & '","maMH":"' & $split_db[2] & '","tenMH":"' & $split_db[3] & '","maNh":"' & $split_db[4] & '","sotc":"' & $split_db[5] & '","strSoTCHP":"' & $split_db[6] & '","ngaythistr":"' & $split_db[7] & '","tietbd":"' & $split_db[8] & '","sotiet":"' & $split_db[9] & '","soTCTichLuyToiThieuMonYeuCau":"' & $split_db[10] & '","choTrung":"' & $split_db[11] & '","soTCMinMonYeuCau":"' & $split_db[12] & '","maKhoiSinhVien":"' & $split_db[13] & '"}'
					ConsoleWrite($post)
					$http = _HttpRequest(4, "http://daotao.hutech.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", $post, $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx?page=dkmonhoc', 'Accept: */*|Accept-Encoding: gzip, deflate|Host:daotao.hutech.edu.vn|X-AjaxPro-Method: DangKySelectedChange')
					$return = StringSplit($http[1], '|')
					If $return[0] > 30 Then
						If Number($return[10]) == 0 Then
							If $return[7] == "" and $return[8] == "" and $return[11] == "" Then
								_Text("[REG] Được đăng ký, đang lưu dữ liệu")
								$post = '{"isValidCoso":false,"isValidTKB":false,"maDK":"' & $split_db[1] & '","maMH":"' & $split_db[2] & '","sotc":"' & $split_db[5] & '","tenMH":"' & $split_db[3] & '","maNh":"' & $split_db[4] & '","strsoTCHP":"' & $split_db[6] & '","isCheck":"true","oldMaDK":"' & $return[5] & '","strngayThi":"' & $split_db[7] & '","tietBD":"' & $split_db[8] & '","soTiet":"' & $split_db[9] & '","isMHDangKyCungKhoiSV":"' & $return[36] & '"}'
								$a  = _HttpRequest(4, "http://daotao.hutech.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", $post, $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method: LuuVaoKetQuaDangKy')
								$b  = _HttpRequest(4, "http://daotao.hutech.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", '{}', $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method: KiemTraTrungNhom')
								$c  = _HttpRequest(4, "http://daotao.hutech.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", '{}', $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method:LuuDanhSachDangKy')
								$d  = _HttpRequest(4, "http://daotao.hutech.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", '{"isCheckSongHanh":false,"ChiaHP":false}', $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method: LuuDanhSachDangKy_HopLe')

								_Text("[REG] Đăng ký hoàn tất, kết quả "&$d[1])
								;TrayTip("Đăng ký môn học", "Đã đăng ký hoàn tất", 5)
								Return True
							Else
								If ($return[7] <> "") Then _Text("[REG] Lỗi " & $return[7])
								If ($return[8] <> "") Then _Text("[REG] Lỗi " & $return[8])
								If ($return[11] <> "") Then _Text("[REG] Lỗi môn này ko thể tự đăng ký do phần tử 11 = " & $return[11])
							EndIf
						Else
							_Text("[REG] Bạn bị trùng lịch môn học này")
						EndIf
					Else
						_Text("[REG] Tách dữ liệu đăng ký thất bại (" & $http[1] & ")")
					EndIf
				Else
					_Text("[REG] Tách dữ liệu môn học thất bại (" & $db[0] & ")")
				EndIf
			Else
				_Text("[REG] Không tìm thấy mã lớp này")
			EndIf
		Else
			_Text("[REG] Không tìm thấy mã môn học này")
		EndIf
		TrayTip("Đăng ký môn học", "Đăng ký môn học gặp lỗi", 5)
	EndIf
EndFunc   ;==>_Reg

Func _Login($times = 0)
	Sleep($_SLEEP)
	GUICtrlSetBkColor($acclb, "-2")
	GUICtrlSetBkColor($passlb, "-2")
	_DisableInput()
	_Text("[LOGIN] Tiến hành đăng nhập")
	$post = '------WebKitFormBoundaryNaE0DIlJYqinZYke' & @CRLF & _
			'Content-Disposition: form-data; name="__EVENTTARGET"' & @CRLF & _
			'' & @CRLF & _
			'' & @CRLF & _
			'------WebKitFormBoundaryNaE0DIlJYqinZYke' & @CRLF & _
			'Content-Disposition: form-data; name="__EVENTARGUMENT"' & @CRLF & _
			'' & @CRLF & _
			'' & @CRLF & _
			'------WebKitFormBoundaryNaE0DIlJYqinZYke' & @CRLF & _
			'Content-Disposition: form-data; name="__VIEWSTATE"' & @CRLF & _
			'' & @CRLF & _
			$__VIEWSTATE & @CRLF & _
			'------WebKitFormBoundaryNaE0DIlJYqinZYke' & @CRLF & _
			'Content-Disposition: form-data; name="ctl00$ContentPlaceHolder1$ctl00$ucDangNhap$txtTaiKhoa"' & @CRLF & _
			'' & @CRLF & _
			GUICtrlRead($acc) & @CRLF & _
			'------WebKitFormBoundaryNaE0DIlJYqinZYke' & @CRLF & _
			'Content-Disposition: form-data; name="ctl00$ContentPlaceHolder1$ctl00$ucDangNhap$txtMatKhau"' & @CRLF & _
			'' & @CRLF & _
			GUICtrlRead($pass) & @CRLF & _
			'------WebKitFormBoundaryNaE0DIlJYqinZYke' & @CRLF & _
			'Content-Disposition: form-data; name="ctl00$ContentPlaceHolder1$ctl00$ucDangNhap$btnDangNhap"' & @CRLF & _
			'' & @CRLF & _
			'Đăng Nhập' & @CRLF & _
			'------WebKitFormBoundaryNaE0DIlJYqinZYke--'
	$http = _HttpRequest(4, "http://daotao.hutech.edu.vn/Default.aspx", $post, $_COOOKIE, 'http://daotao.hutech.edu.vn/Default.aspx', 'Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryNaE0DIlJYqinZYke')
	if @error Then
		_Text("[LOGIN] Không lấy được nội dung trang daotao.hutech.edu.vn")
		Return False
	EndIf

	$__VIEWSTATE = StringRegExp(StringReplace($http[1], @CRLF, ""), 'name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)"', 3)[0]
	$_COOOKIE = _GetCookie($http[0])
	If (StringInStr($http[1], "ctl00_ContentPlaceHolder1_ctl00_ucDangNhap_lblError") > 0) Then
		If (StringInStr($http[1], "Hệ thống đang bận vì quá tải") > 0) Then
			If ($times >= $MAX_TIMES) Then
				_Text("[LOGIN] Hệ thống quá tải, hãy thử lại sau")
				TrayTip("Đăng nhập", "Hệ thống quá tải, hãy thử lại sau", 5)
				_DisableInput(1)
			Else
				_Text("[LOGIN] Hệ thống quá tải, đang thử lại lần " & $times + 1 & "/" &$MAX_TIMES)
				_Login($times + 1)
			EndIf
		ElseIf (StringInStr($http[1], "Sai thông tin") > 0) Then
			TrayTip("Đăng nhập", "Sai thông tin đăng nhập", 5)
			_Text("[LOGIN] Sai thông tin đăng nhập")
			GUICtrlSetBkColor($acclb, "0xf4564d")
			GUICtrlSetBkColor($passlb, "0xf4564d")
			_DisableInput(1)
		Else
			TrayTip("Đăng nhập", "Lỗi không xác định", 5)
			_Text("[LOGIN] Lỗi không xác định")
			_DisableInput(1)
		EndIf
	ElseIf (StringInStr($http[1], "ctl00_Header1_ucLogout_lblNguoiDung") > 0) Then
		$tach = StringRegExp(StringReplace($http[1], @CRLF, ""), 'font color="#FF3300">Chào (.*?)<', 3)
		If (UBound($tach) <= 0) Then Return _Login()
		$name = $tach[0]
		GUICtrlSetData($edittxt, '')
		_Text("[LOGIN] ĐĂNG NHẬP THÀNH CÔNG")
		_Text("[LOGIN] Xin chào " & $name)
		_Text("-------------------------------------------------------")
		_Text("- Lệnh 'list@<Mã MH>' lấy ra list mã môn học")
		_Text("- Lệnh 'reg@<Mã MH>@<NMH>' đăng ký môn học theo yêu cầu")
		_Text("-------------------------------------------------------")
		WinSetTitle($LoginGUI, '', $name)
		TrayTip("Đăng nhập", "Xin chào " & $name, 5)
		_DisableInput(2)
		Return True
	ElseIf (StringInStr($http[1], "ctl00_ContentPlaceHolder1_ctl00_lblCapcha") > 0) Then
		_Text("[LOGIN] Phiên đăng nhập hết hạn, đang lấy lại captcha và đăng nhập lại")
		If (_Captcha()) Then Return _Login()
	Elseif ($http[1] = "The service is unavailable.") Then
		_Text("[LOGIN] Trang daotao.hutech.edu.vn hiện không còn hoạt động")
	EndIf
	Return False
EndFunc   ;==>_Login

Func _DisableInput($id = 0)
	If ($id = 0) Then
		GUICtrlSetState($acc, $GUI_DISABLE)
		GUICtrlSetState($pass, $GUI_DISABLE)
		GUICtrlSetData($login, 'LOGOUT')
	ElseIf ($id = 1) Then
		GUICtrlSetState($acc, $GUI_ENABLE)
		GUICtrlSetState($pass, $GUI_ENABLE)
		GUICtrlSetData($login, 'LOGIN')
	EndIf
	If ($id = 2) Then
		GUICtrlSetState($command, $GUI_ENABLE)
		GUICtrlSetState($cmdbtn, $GUI_ENABLE)
	ElseIf ($id = 3) Then
		GUICtrlSetState($command, $GUI_DISABLE)
		GUICtrlSetState($cmdbtn, $GUI_DISABLE)
	EndIf
EndFunc   ;==>_DisableInput