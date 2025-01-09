#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} User Function M410STTS
	Este ponto de entrada pertence à rotina de pedidos de venda, MATA410().
	Está em todas as rotinas de inclusão, alteração, exclusão, cópia e devolução de compras.
	Executado após todas as alterações no arquivo de pedidos terem sido feitas
	@type  M410STTS
	@author TOTVS Nordeste (Elvis Siqueira)
	@since 09/01/2025
	@version 1.0
	@param
	nOper --> Tipo: Numérico - Descrição: Operação que está sendo executada, sendo:
		3 - Inclusão
		4 - Alteração
		5 - Exclusão
		6 - Cópia
		7 - Devolução de Compras
	@return
	@example
	@see (https://tdn.totvs.com/pages/releaseview.action?pageId=6784155)
	/*/

User Function M410STTS()

	Local aRet       := {}
	Local aArea      := GetArea()
	Local aAreaSC5   := SC5->(GetArea())
	Local lIntFusion := SuperGetMv("PC_INTFUSI",.F.,.T.) // Incluido parametro de integração com o Fusion - Default .T.
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
			// -- Parâmetro: 1   - Normal, B - Bloqueado, 4 - Faturado ou 9 - Cancelar
			// --            S   = Pode formar carga
			// --            .T. = N. Carga
			// --            4   - Nº da Nota Fiscal para atualização no Pedido
			// --            5   - Série da Nota Fiscal para atualização no Pedido
			// -------------------------------------------------------
			oFusion:saveEntregaServico("9","N",.F.,cNota,cSerie)
			aRet := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION
			
			If !aRet[01]
            	ApMsgAlert(aRet[02],"ATENÇÃO - Integração Fusion")
          	EndIf
		EndIf
	EndIF

	RestArea(aAreaSC5)
	RestArea(aArea)
Return
