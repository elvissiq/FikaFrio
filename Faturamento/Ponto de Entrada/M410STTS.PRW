#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} User Function M410STTS
	Este ponto de entrada pertence � rotina de pedidos de venda, MATA410().
	Est� em todas as rotinas de inclus�o, altera��o, exclus�o, c�pia e devolu��o de compras.
	Executado ap�s todas as altera��es no arquivo de pedidos terem sido feitas
	@type  M410STTS
	@author TOTVS Nordeste (Elvis Siqueira)
	@since 09/01/2025
	@version 1.0
	@param
	nOper --> Tipo: Num�rico - Descri��o: Opera��o que est� sendo executada, sendo:
		3 - Inclus�o
		4 - Altera��o
		5 - Exclus�o
		6 - C�pia
		7 - Devolu��o de Compras
	@return
	@example
	@see (https://tdn.totvs.com/pages/releaseview.action?pageId=6784155)
	/*/

User Function M410STTS()

	Local aRet       := {}
	Local aArea      := GetArea()
	Local aAreaSC5   := SC5->(GetArea())
	Local lIntFusion := SuperGetMv("PC_INTFUSI",.F.,.T.) // Incluido parametro de integra��o com o Fusion - Default .T.
	Local oFusion    := IIF(lIntFusion, PCLSFUSION():New(), "")
	Local _nOper     := PARAMIXB[1]
	Local nSeqFus    := 0
	Local cNota      := ""
	Local cSerie     := ""
	Local cCarga     := ""
	Local cSeqCar    := ""
	
	IF _nOper == 5 .AND. SC5->C5_XSTATUS == "S"
		aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nSeqFus,.F.,cNota,cSerie,cCarga,cSeqCar)
		
		If aRet[01]
			oFusion:aRegistro := IIf(Len(aRet[04]) > 0,aRet[04],aRet[03])  // Registro do Pedido de Venda
			// -- Par�metro: 1   - Normal, B - Bloqueado, 4 - Faturado ou 9 - Cancelar
			// --            S   = Pode formar carga
			// --            .T. = N. Carga
			// --            4   - N� da Nota Fiscal para atualiza��o no Pedido
			// --            5   - S�rie da Nota Fiscal para atualiza��o no Pedido
			// -------------------------------------------------------
			oFusion:saveEntregaServico("9","N",.F.,cNota,cSerie)
			aRet := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION
			
			If !aRet[01]
            	ApMsgAlert(aRet[02],"ATEN��O - Integra��o Fusion")
          	EndIf
		EndIf
	EndIF

	RestArea(aAreaSC5)
	RestArea(aArea)
Return
