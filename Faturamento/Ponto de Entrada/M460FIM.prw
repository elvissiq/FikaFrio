#Include "TOTVS.CH"

//---------------------------------------------------------
/*/ Rotina MATA460 
  Ponto de entrada M460FIM

   Grava��o dos dados ap�s gerar a NF de Sa�da
   Este P.E. � chamado ap�s a grava��o da NF de Sa�da e
   fora da transa��o.
    
   Implementado para:
    - Enviar o n�mero da NF para FUSION.

  @parametros PARAMIXB[1] - N�mero da NF
              PARAMIXB[2] - S�rie da NF
              PARAMIXB[3] - Cliente/fornecedor da NF
              PARAMIXB[4] - Loja da NF
  @author Anderson Almeida - TOTVS
  @since   17/10/2024 
/*/
//----------------------------------------------------------
User Function M460FIM()
//  Local cNumNFS   := ParamIXB[1]       // N�mero da NF
//  Local cSerieNFS := ParamIXB[2]       // S�rie da NF
//  Local cClieFor  := ParamIXB[3]       // Cliente/fornecedor da NF
//  Local cLoja     := ParamIXB[4]       // Loja da NF
  Local cNumNFS   := SF2->F2_DOC       // N�mero da NF
  Local cSerieNFS := SF2->F2_SERIE     // S�rie da NF
  Local cClieFor  := SF2->F2_CLIENTE   // Cliente/fornecedor da NF
  Local cLoja     := SF2->F2_LOJA      // Loja da NF

  Local oFusion   := PCLSFUSION():New()
  Local aRet      := {}
  Local cQry      := ""

  If Empty(SF2->F2_CARGA)
     Return
  EndIf

  cQry := "Select SD2.D2_PEDIDO, SC9.C9_XSEQFUS"
  cQry += "  from " + RetSQLName("SD2") + " SD2, " + RetSQLName("SC9") + " SC9"
  cQry += "   where SD2.D_E_L_E_T_ <> '*' "
  cQry += "     and SD2.D2_FILIAL  = '" + FWxFilial("SD2") + "'"
  cQry += "     and SD2.D2_CLIENTE = '" + cClieFor + "'"
  cQry += "     and SD2.D2_LOJA    = '" + cLoja + "'"
  cQry += "     and SD2.D2_DOC     = '" + cNumNFS + "'"
  cQry += "     and SD2.D2_SERIE   = '" + cSerieNFS + "'"
  cQry += "     and SC9.D_E_L_E_T_ <> '*'"
  cQry += "     and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
  cQry += "     and SC9.C9_NFISCAL = '" + cNumNFS + "'"
  cQry += "     and SC9.C9_SERIENF = '" + cSerieNFS + "'"
  cQry := ChangeQuery(cQry) 
  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TSD2",.F.,.T.)
 
  If ! TSD2->(Eof())
     aRet := oFusion:lerPedidoVenda(TSD2->D2_PEDIDO, Val(TSD2->C9_XSEQFUS), .F., SF2->F2_DOC, SF2->F2_SERIE,"","")

     If aRet[01]
        If Len(aRet[04]) > 0                                   // Itens do Pedido de Venda Liberada
           oFusion:aRegistro := aRet[04] 

           oFusion:saveEntregaServico("4","N",.T.,SF2->F2_DOC,SF2->F2_SERIE)     // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
          
           aRet := oFusion:Enviar("saveEntregaServico")        // Enviar para FUSION

           If ! aRet[01]
              ApMsgAlert(aRet[02],"ATEN��O")  
           EndIf
        EndIf
      else
        ApMsgAlert(aRet[02],"ATEN��O")	    
	 EndIf
  EndIf

  TSD2->(dbCloseArea()) 
Return
