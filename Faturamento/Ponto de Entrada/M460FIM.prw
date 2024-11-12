#Include "TOTVS.CH"

//---------------------------------------------------------
/*/ Rotina MATA460 
  Ponto de entrada M460FIM

   Gravação dos dados após gerar a NF de Saída
    
    Implementado para:
      - Enviar o número da NF para FUSION.

  @author Anderson Almeida - TOTVS
  @since   17/10/2024 
/*/
//----------------------------------------------------------
User Function M460FIM()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local cQry    := ""

  If Empty(SF2->F2_CARGA)
     Return
  EndIf

  cQry := "Select SD2.D2_PEDIDO, SC9.C9_XSEQFUS"
  cQry += "  from " + RetSQLName("SD2") + " SD2, " + RetSQLName("SC9") + " SC9"
  cQry += "   where SD2.D_E_L_E_T_ <> '*' "
  cQry += "     and SD2.D2_FILIAL  = '" + FWxFilial("SD2") + "'"
  cQry += "     and SD2.D2_CLIENTE = '" + SF2->F2_CLIENTE + "'"
  cQry += "     and SD2.D2_LOJA    = '" + SF2->F2_LOJA + "'"
  cQry += "     and SD2.D2_DOC     = '" + SF2->F2_DOC + "'"
  cQry += "     and SD2.D2_SERIE   = '" + SF2->F2_SERIE + "'"
  cQry += "     and SC9.D_E_L_E_T_ <> '*'"
  cQry += "     and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
  cQry += "     and SC9.C9_NFISCAL = '" + SF2->F2_DOC + "'"
  cQry += "     and SC9.C9_SERIENF = '" + SF2->F2_SERIE + "'"
  cQry := ChangeQuery(cQry) 
  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TSD2",.F.,.T.)
	
  If ! TSD2->(Eof())
     aRet := oFusion:lerPedidoVenda(TSD2->D2_PEDIDO, Val(TSD2->C9_XSEQFUS), .F., SF2->F2_DOC, SF2->F2_SERIE)

     If aRet[01]
        If Len(aRet[04]) > 0                                   // Itens do Pedido de Venda Liberada
           oFusion:aRegistro := aRet[04] 

           oFusion:saveEntregaServico("1","S",.F.)             // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
           
           aRet := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION

           If aRet[01]
              ApMsgInfo("Número da NF enviado para FUSION com sucesso.")
            else
              ApMsgAlert(aRet[02],"ATENÇÃO")  
           EndIf
        EndIf
      else
        ApMsgAlert(aRet[02],"ATENÇÃO")	    
	 EndIf
  EndIf

  TSD2->(dbCloseArea()) 
Return
