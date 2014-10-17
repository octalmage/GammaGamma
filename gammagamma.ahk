#singleinstance force
#include Gdip.ahk

onexit, cleanup

max=5800
min=4000
weatherurl = http://www.wolframalpha.com/input/?i=sun
alt=http://www.wolframalpha.com/input/?i=Sun+next+maximum+altitude+time
ProgramName=GammaGamma
cur=6500




If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}



;RGB defaults for each gamma level used. 
6500k=128, 128, 128
5200k=129, 110, 90
3800k=130, 86, 38
3400k=131, 75, 8
kSplit("6500k")
kSplit("5200k")
kSplit("3800k")
kSplit("3400k")


menu, tray, NoStandard
menu, tray, add, Main, Main
menu, tray, add, Settings, settings
menu, tray, add ; separator
menu, tray,add,Exit,cleanup

menu, tray, default, Main

gosub auto

settimer,auto,60000





;glideto(3400)



return



auto:
	gosub, process
	FormatTime, curtime, , h:mm tt
	nowh:=A_Hour

	StringSplit, curtime_a, curtime , :
	StringSplit, sunloc_a, sunloc , :
	sunloch=%sunloc_a1%

	If instr(sunloc,"pm")
		sunloch+=12

	;nowh=12

		tillrise:=abs(nowh-sunriseh)
	sincerise:=nowh-sunriseh
	tillset:=sunseth-nowh
	/*
	If (nowh>=sunriseh and nowh<=sunloch)
	{
	
		tilltop:=sunloch+(sunloch-nowh)
		;nowk:=(round((3100*tilltop)/13,-2)+3400)-(6500-max)
		nowk:=round(((nowh*3100)/sunloch)+3400,-2)-(6500-max)

	}
	else if (nowh<sunseth and nowh>sunloch)
	{
		nowk:=max
	}
	Else if (nowh>=sunseth)
	{
		nowk:=min
		
	}
	else 
	{
		nowk:=(round((nowh*3100)/sunriseh,-2)+min)-(6500-max)
		msgbox %nowk%
	}
	*/
	
	
	if (nowh<=sunriseh)
		nowk:=min
	else if (nowh>sunriseh and nowh<sunloch)
	{
		nowk:=max
	}
	else if (nowh=sunloch or (nowh>sunloch and nowh<(sunseth-2)))
		nowk:=max
	else if (nowh>=(sunset-2))
	{
		nowk:=max-(round(min*((nowh-(sunseth))/10),-2))
	
	}
	
		
	
	
	If not nowk
		return



	find(nowk)

	to_var=%nowk%k
	nowk_o:=%to_var%


	stringsplit, nowk_a, nowk_o, `,, %a_space%




	;set(nowk_a1, nowk_a2, nowk_a3)
	guicontrol, , Edit1, %nowk_o%
	guicontrol, , Edit2, %nowk%k
	nowks:=nowk/100


	guicontrol, , sr, %nowk_a1%
	guicontrol, , sg, %nowk_a2%
	guicontrol, , sb, %nowk_a3%
	guicontrol, , sk, %nowks%


	guicontrol, , srs, %nowk_a1%
	guicontrol, , sgs, %nowk_a2%
	guicontrol, , sbs, %nowk_a3%
	guicontrol, , sks, %nowk%



	;gosub Main
	glideto(nowk)
	set(nowk_a1,nowk_a2,nowk_a3)
	cur:=nowk
return

#r::
reload

animate:
	split=1000
	gui 2: default

	Sunt:=(a_Hour-sunriseh)-2
	start:=round((sunt*100)/24)

	skip=10
	suntt:=(sunloch-sunriseh)-2
	topt:=round((suntt*100)/24)
	oasleep=10
	sloop=1
	sskip:=skip
	Loop %split%
	{
		If (start>split)
			start=1


		If (start<topt)
		{
			test:=round(topt*start)
			skip:=sskip-test
		}
		Else
			skip:=sskip

		drawsundiagram(ByRef sundia,start,split)
		start:=start+skip

		sleep %asleep%
	}
	drawsundiagram(ByRef sundia)
	gui 1: default
return


setcolor:
	gui,submit, nohide

	;nsr:=torgb(sr)
	;nsg:=torgb(sg)
	;nsb:=torgb(sb)
	;rgbstring=%nsr%, %nsg%, %nsb%
	If not (cc=occ)
	{
		stringsplit, cc_a, cc, `,, %a_space%
		set(cc_a1, cc_a2, cc_a3)
		occ:=cc
	}
	Else
	{
		set(sr,sg,sb)
		rgbstring=%sr%, %sg%, %sb%
		guicontrol, , Edit1, %rgbstring%
	}



return
act:

	gosub setcolor
return


setk:
	this=
	sk=
	to_var=
	gui,submit,nohide
	skog:=sk
	sk:=sk*100
	find(sk)

	to_var=%sk%k
	sk_o:=%to_var%
	guicontrol, , Edit1, %sk_o%
	guicontrol, , Edit2, %sk%k
	stringsplit, sk_a, sk_o, `,, %a_space%
	set(sk_a1, sk_a2, sk_a3)


	guicontrol, , sr, %sk_a1%
	guicontrol, , sg, %sk_a2%
	guicontrol, , sb, %sk_a3%
	guicontrol, , sk, %skog%



	guicontrol, , srs, %sk_a1%
	guicontrol, , sgs, %sk_a2%
	guicontrol, , sbs, %sk_a3%
	guicontrol, , sks, %sk%

	;tooltip %sk%
	;set(sr,sg,sb)
return

;This function take a percent and turns it into a rgb value.
;Totally unnessearry since the slider control has a range option.
torgb(n)
	{
		return % round(n*2.554)
	}



find(k)
	{
		global
		local full, b
		If (k<=6500 and k>5200)
		{
			z1=6500
			z2=5200
		}
		Else If (k<=5200 and k>3800)
		{
			z1=5200
			z2=3800
		}
		Else If (k<=3800 and k>=3400)
		{
			z1=3800
			z2=3400
		}
		Else
		{
			error_m=Kelvin out of range.
			return 0
		}
		If (k<z1 and k>z2)
		{
			Loop 3
			{
				If a_index=1
					rgb=r
				Else If a_index=2
					rgb=g
				Else
					rgb=b
				x1:=%z1%k%rgb%
				x2:=%z2%k%rgb%
				a:=abs((x1-x2))/(z1-z2)
				b:=x1
				while(b>x2)
				{
					b:=b-a
					t=%a_index%
					If (t=(z1-k))
						break
				}
				b:=round(b)
			%k%k%rgb%:=b
			If rgb=b
				full=%full%%b%
			Else
				full=%full%%b%,
		}
		%k%k:=full
		return full

	}
}



kSplit(k)
	{
		global
		local k_a, kv
		kv:=%k%
		stringsplit, k_a, kv, `, , %a_space%
		%k%r:=k_a1
		%k%g:=k_a2
		%k%b:=k_a3
	}


;This function sets the rgb values of the Gamma Ramp.
set(r=128,g=128,b=128)
	{
		b1:=r ; brightness, in the range of 0 - 255, where 128 is normal
		b2:=g
		b3:=b
		If  not (b1>0 and b1<=255 and b2>0 and b2<=255 and b3>0 and b3<=255)
			return 0

		VarSetCapacity(gr, 512*3)
		Loop,   256
		{
			If  (nValue1:=(b1+128)*(A_Index-1))>65535
				nValue1:=65535
			If  (nValue2:=(b2+128)*(A_Index-1))>65535
				nValue2:=65535
			If  (nValue3:=(b3+128)*(A_Index-1))>65535
				nValue3:=65535
			NumPut(nValue1, gr,      2*(A_Index-1), "Ushort")
			NumPut(nValue2, gr,  512+2*(A_Index-1), "Ushort")
			NumPut(nValue3, gr, 1024+2*(A_Index-1), "Ushort")
		}
		hDC := DllCall("GetDC", "Uint", 0)
		DllCall("SetDeviceGammaRamp", "Uint", hDC, "Uint", &gr)
		DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
		return 1
	}

glideto(k)
	{
		global cur
		global sincerise
		If (k<3400 or k>6500)
			return
		
		i:=cur

		while(i!=k)
		{
			If (k>=cur)
				i+=5
			Else
				i-=5

			sk:=find(i)

			stringsplit, sk_a, sk, `,, %a_space%
			set(sk_a1, sk_a2, sk_a3)

			
			sleep 10
		}



	}

settings:
	gui, destroy
	gui, font, s14
	gui,add,text,section, Red:
	gui,add,text,, Green:
	gui,add,text,, Blue:
	gui,add,text,, Kelvin:

	;gui,add,button,gsetcolor,Set

	gui,add,button,,Done

	Gui, Add, Slider,ys vsr gact section AltSubmit Range1-255, 128
	Gui, Add, Slider, vsg gact AltSubmit Range1-255, 117
	Gui, Add, Slider, vsb gact AltSubmit Range1-255, 105
	Gui, Add, Slider, vsk gsetk yp+50   AltSubmit Range34-65, 65
	gui,add,edit,hidden vcc, 128, 128, 128
	gui,add,edit,hidden vck, 6500k



	gui,add,text,ys vsrs, 128
	gui,add,text,vsgs, 128
	gui,add,text,vsbs, 128
	gui,add,text,vsks , 6500


	gui,show,autosize,Settings

return


Main:
sinceset:=nowh-sunseth
if sinceset>1
	plur=s
	
	if (nowh>sunloch and nowh<sunseth)
		suninfo=Sunset in %tillset% hours: currently %nowk%k
	else if (nowh>sunriseh and nowh< sunloch)
		suninfo=Sunrise: %sincerise% hours ago: currently %nowk%k
	else if (nowh>=sunseth and nowh>sunriseh)
		suninfo=Sunset: %sinceset% hour%plur% ago: currently %nowk%k
	else 
		suninfo=Sunrise in %tillrise% hours: currently %nowk%k
	
	gui 2: default
	gui, destroy
	OnMessage(0x201, "WM_LBUTTONDOWN")
	gui, color, 0xe4e3e1,
	gui,add,picture, y-2 x-2 0xE w522 vtitlebar h25 ,
	gui,font, bold c333333
	gui,add, text,xm y5 +BackgroundTrans, %ProgramName%
	gui,font, normal c666666
	gui,add, text,xm vsunriseinfo, %suninfo%
	gui,add,picture,  0xE w500 h200 vsundia h200 ,
	gui,add,checkbox, yp+170, Disable for one hour
	gui,font, s8
	gui,add, button,+backgroundtrans +0x8000 +0x300 -Default gclosemain  w15 h15 x500 y5 , x
	;gui,add, picture,+backgroundtrans 0xE w15 h15 x500 y5 vclosebutton
	gui,show,w530 h225,%ProgramName%
	Gui, 2:  +Lastfound -Caption +alwaysontop
	hGui:=winexist()

WinSet, Transparent, 245, ahk_id %hGui%

	drawtitlebar(titlebar)
	drawsundiagram(sundia)
	;drawclosebutton(closebutton)
	WinSet, redraw, ,ahk_id %hGui%
	WinGetPos , , , tw, th, ahk_id %hGui%
	tw-=15
	WinSet, Region, 0-0 W%tw% H%th% R10-10, ahk_id %hGui%





	gui 1: default

return

cleanup:
	set()
	exitapp



	WM_LBUTTONDOWN() {
	If (A_Gui) {
		Gui, +LastFound
		PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN
	}
	}


process:
	URLDownloadToFile, %weatherurl% , daylight.htm
	fileread, filein, daylight.htm
	FileDelete, daylight.htm


	;Find the position of the AM and PM times.
	sunriseloc := RegExMatch(filein, "\d+:\d+ am")

	sunsetloc := RegExMatch(filein, "\d+:\d+ pm")


	;Strip out the AM and PM times to  variables.
	stringmid, sunrise, filein, %sunriseloc%, 7
	stringmid, sunset, filein, %sunsetloc%, 7
	sunaltstart:=sunsetloc+11
	sunaltloc := RegExMatch(filein, "\d+:\d+ pm","",sunaltstart)

	stringmid, sunloc, filein, %sunaltloc%, 7

	;Test Fields
	;sunrise =  8:00 AM
	;sunset = 8:00 PM

	;split into hours and minutes
	Loop, parse, sunrise, :
	{
		If (A_Index = 1)
			sunriseh:=A_LoopField
		Else If (A_Index = 2)
			sunrisemampm:=A_LoopField
	}
	Loop, parse, sunrisemampm, %a_space%
	{
		If (A_Index = 1)
			sunrisem:=A_LoopField
		Else If (A_Index = 2)
			sunriseampm:=A_LoopField
	}
	Loop, parse, sunset, :
	{
		If (A_Index = 1)
			sunseth:=A_LoopField
		Else If (A_Index = 2)
			sunsetmampm:=A_LoopField
	}
	Loop, parse, sunsetmampm, %a_space%
	{
		If (A_Index = 1)
			sunsetm:=A_LoopField
		Else If (A_Index = 2)
			sunsetampm:=A_LoopField
	}

	;get current time
	FormatTime, curch, , HH
	FormatTime, curcm, , mm

	;Test Fields
	;curch=24
	;curcm=00

	;update gui with values
	;GuiControl,,sunrise,%sunriseh%:%sunrisem% %sunriseampm%
	;GuiControl,,sunset,%sunseth%:%sunsetm% %sunsetampm%

	;figure out difference between current time and sunset
	sunseth:=sunseth+12 ;add 12 becuase the sun sets in the afternoon

	;calculate hours remaining
	If (sunriseh < curch)
	{
		sundif:=sunseth-curch
	}
	Else
		sundif=0

	;calculate progres bar value
	totalhours := sunseth-sunriseh
	progresrate := 100/totalhours
	progressset := progresrate * sundif

	if(sundif<0)
	sundif=0

	;update gui with values
	;GuiControl,,hoursleft, %sundif%
	;GuiControl,,progressbar, %progressset%


Return


closemain:
	gui 2: destroy
return

drawtitlebar(ByRef Variable)
	{
		th=10
		GuiControlGet, Pos, Pos, Variable

		GuiControlGet, hwnd, hwnd, Variable
		pBrushFront := Gdip_BrushCreateSolid(0xff000000), pBrushBack := Gdip_BrushCreateSolid(0xffb8b8b8)

		; Create a gdi+ bitmap the width and height that we found the picture control to be
		; We will then get a reference to the graphics of this bitmap
		; We will also set the smoothing mode of the graphics to 4 (Antialias) to make the shapes we use smooth
		pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)

		; We will fill the background colour with out background brush
		; x = 0, y = 0, w = Posw, h = Posh
		;Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
		Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
		; ... and set it to the hwnd we found for the picture control
		SetImage(hwnd, hBitmap)

		; We then must delete everything we created
		; So the 2 brushes must be deleted
		; Then we can delete the graphics, our gdi+ bitmap and the gdi bitmap
		Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
		Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
		Return, 0


	}
	
	
	
	drawclosebutton(ByRef Variable)
	{
		th=10
		GuiControlGet, Pos, Pos, Variable

		GuiControlGet, hwnd, hwnd, Variable
		pBrushFront := Gdip_BrushCreateSolid(0xff000000), pBrushBack := Gdip_BrushCreateSolid(0xffcdcdcd)

		; Create a gdi+ bitmap the width and height that we found the picture control to be
		; We will then get a reference to the graphics of this bitmap
		; We will also set the smoothing mode of the graphics to 4 (Antialias) to make the shapes we use smooth
		pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)

		; We will fill the background colour with out background brush
		; x = 0, y = 0, w = Posw, h = Posh
		;Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
		;Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
		Gdip_FillRoundedRectangle(G, pBrushBack, 0, 0, Posw, Posh, 2)
		pPen := Gdip_CreatePen(0xff666666, 2)
		Gdip_DrawLine(g, pPen, 2, 2, Posw-3, Posh-3)
		Gdip_DrawLine(g, pPen, Posw-3, 2, 2, Posh-3)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
		; ... and set it to the hwnd we found for the picture control
		SetImage(hwnd, hBitmap)

		; We then must delete everything we created
		; So the 2 brushes must be deleted
		; Then we can delete the graphics, our gdi+ bitmap and the gdi bitmap
		Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
		Gdip_DeletePen(pPen)
		Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
		Return, 0


	}



drawsundiagram(ByRef Variable, spos=-1,split=24)
	{
		th=10
		global totalhours
		global sunriseh
		GuiControlGet, Pos, Pos, Static4

		GuiControlGet, hwnd, hwnd, Static4
		pBrushFront := Gdip_BrushCreateSolid(0xff000000), pBrushBack := Gdip_BrushCreateSolid(0xffE1E1E1),  pBrushOut := Gdip_BrushCreateSolid(0xffffffff), pBot := Gdip_BrushCreateSolid(0xffF3EBE5)

		; Create a gdi+ bitmap the width and height that we found the picture control to be
		; We will then get a reference to the graphics of this bitmap
		; We will also set the smoothing mode of the graphics to 4 (Antialias) to make the shapes we use smooth
		pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)

		pPen := Gdip_CreatePen(0xffffffff, 2)

		pSun := Gdip_BrushCreateSolid(0xffFF921D)

		; We will fill the background colour with out background brush
		; x = 0, y = 0, w = Posw, h = Posh
		;Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, Posh)
		Gdip_FillRectangle(G, pBrushBack, 0, 0, Posw, (Posh/2))
		Gdip_FillRectangle(G, pBot, 0, (Posh/2), Posw, 50)
		Gdip_DrawLine(g, pPen, 0,(Posh/2), 500, (Posh/2))
		Gdip_DrawRectangle(G, pPen, 0, 0, Posw-1, 150)
		Gdip_DrawBezier(g, pPen, 0, 100, 200, -100, 350, 250, 500, 100)
		blist:= 2D_Bezier(0, 100, 200, -100, 350, 250, 500, 100, split)
		
		If (spos=-1)
		{
			spos=%a_Hour%
			Sunt:=(spos-sunriseh)
			If sunt<=0
			{
				sunt:=sunt+split
			}
		}
		Else
		{
	
			Sunt:=spos
		}

	
	
		StringSplit, barray, blist ,`n
		StringSplit, bpos, barray%Sunt% , `,

		if sunt=1
		{
			bpos1:=0
			bpos2:=100
		}
		else if sunt=24
		{
			bpos1:=500
			bpos2:=100
		}
		

		Gdip_FillEllipse(g, pSun, bpos1-10, bpos2-10, 20, 20)
		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
		; ... and set it to the hwnd we found for the picture control
		SetImage(hwnd, hBitmap)

		; We then must delete everything we created
		; So the 2 brushes must be deleted
		; Then we can delete the graphics, our gdi+ bitmap and the gdi bitmap
		Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack),Gdip_DeleteBrush(pBrushOut), Gdip_DeletePen(pPen), Gdip_DeleteBrush(pSun),Gdip_DeleteBrush(pBot)
		Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
		Return, 0


	}



2D_Bezier( px0, py0, px1, py1, px2, py2, px3, py3, Segments ) { ; ----------------------------------
		; Function by [VxE]. Returns a newline-separated list of (N-1) points which lie on the cubic bézier
		; curve described by the four input points. NOTE: the returned points will be in FLOATING POINT
		; format if, and only if, px0 contains a decimal. Otherwise, the returned points will be rounded to
		; integers. More info about Bézier curves @ http://en.wikipedia.org/wiki/B%C3%A9zier_curve
		; NOTE: the points (px0, py0) and (px3,py3) are always omitted from the returned list.
		; Code Source: http://www.autohotkey.com/forum/viewtopic.php?p=374641#374641
		UseFloat := InStr( px0, "." )
		Loop % Segments - 1
		{
			u := 1 - t := A_Index / Segments
			bx := px0 * u**3 + 3 * px1 * t * u**2 + 3 * px2 * u * t**2 + px3 * t**3
			by := py0 * u**3 + 3 * py1 * t * u**2 + 3 * py2 * u * t**2 + py3 * t**3
			PointsList .= "`n" . ( UseFloat ? bx . "," . by : Round( bx ) . "," . Round( by ) )
		}
		Return SubStr( PointsList, 2 )
	}
