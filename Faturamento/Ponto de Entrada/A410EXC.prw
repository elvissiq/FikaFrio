#Include "TOTVS.ch"

//--------------------------------------------------------
/*/ Rotina MATA440 
  Ponto de entrada M410T

    Este ponto é executado após o fechamento da transação
    de liberação do pedido de venda (Automática).
    
    Implementado para:
      - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   20/01/2025 
/*/
//--------------------------------------------------------
User Function A410EXC()
  Local lRet    := .T.
  Local oFusion := PCLSFUSION():New()
  Local nSeqFus := 0
  Local aRet    := {}

  If SC5->C5_TPCARGA == "1" .and. SC5->C5_XSTATUS == "S"
	   aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nSeqFus,.F.,"","","","")
		
	   If aRet[01]
		    oFusion:aRegistro := IIf(Len(aRet[04]) > 0,aRet[04],aRet[03])
	
       // -- Parâmetro: 1   - Normal, B - Bloqueado, 4 - Faturado ou 9 - Cancelar
	     // --            S   - Pode formar carga
	     // --            .T. - N. Carga
	     // --            4   - Nº da Nota Fiscal para atualização no Pedido
	     // --            5   - Série da Nota Fiscal para atualização no Pedido
	     // -------------------------------------------------------
		    oFusion:saveEntregaServico("9","N",.F.,"","")

		    aRet := oFusion:Enviar("saveEntregaServico")
			
		    If ! aRet[01]
           ApMsgAlert(aRet[02],"ATENÇÃO - Integração Fusion")

           lRet := .F.
        EndIf
	   EndIf 
  EndIf
Return lRet
