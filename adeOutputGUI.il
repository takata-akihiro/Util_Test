;==============================================================================
ADEOUT_DCOP_LIST = list("vgt" "region")
;ADEOUT_DCOP_LIST = list("vgt" "region" "vgs" "vth" "vds" "vdssat" "ids" "gm")
;==============================================================================

procedure(setAdexlSession(testName)
	prog(()
		my_adexl_session = axlGetWindowSession()
		if(my_adexl_session == nil || my_adexl_session == ""
		then
			print("*Error* Setting ADEXL session failed", errport)
			return(nil)
		)
		my_adexl_test_name = testName
		if(my_adexl_test_name == nil || my_adexl_test_name == ""
		then
			print("*Error* Setting ADEXL test name failed", errport)
			return(nil)
		)
		print("ADEXL session set")
		return(t)
	)
)

procedure(addToOutput()
	prog((adexl_test, adexl_session, lout, exp, dcop)

		selObj = geGetSelSet()
		when(selObj == nil
			return("Device Not Selected")
		)


		foreach(obj selObj
			instName = strcat(geGetInstHier(hiGetCurrentWindow()), "/", obj~>baseName)

;======================================================================================================
				exp = strcat("OP(\"" instName "\"\,\"vds\")" "\-" "OP(\"" instName "\"\,\"vdssat\")")
        lout = getOutputName("vds_margin" obj~>baseName)
				axlAddOutputExpr(my_adexl_session my_adexl_test_name lout ?expr exp)

;Add here (copy above 3 lines and modify parameter name such as vds, vdssat to the others)

;				exp = strcat("OP(\"" instName "\"\,\"vgs\")" "\-" "OP(\"" instName "\"\,\"vth\")")
;       lout = getOutputName("vov" obj~>baseName)
;				axlAddOutputExpr(my_adexl_session my_adexl_test_name lout ?expr exp)

;======================================================================================================

			foreach(dcop ADEOUT_DCOP_LIST
				exp = strcat("OP(\"" instName "\" \"" dcop "\")")
				lout = getOutputName(dcop obj~>baseName)
				printf(strcat("adding...  " exp))
				printf("\n")
				axlAddOutputExpr(my_adexl_session my_adexl_test_name lout ?expr exp)
			)
		)
	)
)

procedure(getOutputName(p, q)
	prog((prefix1, pre)
		prefix1 = MyADEOutput~>prefix1~>value
		pre = strcat(prefix1 q "_")
		if(pre == ""
		then
			return("")
		else
			return(strcat(pre p))
		)
	)
)


hiCreateAppForm(
    ?name 'MyADEOutput
		?formTitle "GUI for adeOutput"
    ?fields list(
; adexl
        hiCreateStringField(
            ?name 'adexl_test_name
            ?prompt "Enter ADEXL test name"
            )
        hiCreateButton(
            ?name 'set_adexl_session
            ?buttonText "Set ADEXL session (ADEXL view needs to be active)"
            ?callback "setAdexlSession(hiGetCurrentForm()~>adexl_test_name~>value)"
            )
; prefix
        hiCreateStringField(
            ?name 'prefix1
            ?prompt "Output name prefix"
            )
        )
		?callback list("addToOutput()" nil)
    )

hiDisplayForm(MyADEOutput)
