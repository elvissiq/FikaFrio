#Include "TOTVS.CH"
#Include "FWMBrowse.ch"

//---------------------------------------------------------
/*/ Rotina MATA460B 
  Ponto de entrada OM460MNU

   Este Ponto de Entrada permite manipular as op��es do menu 
   A��es Relacionadas, da rotina Documento de Sa�da Por Carga 
   (MATA460B), sendo tanto a inclus�o como a exclus�o de op��es.
    
    Implementado para:
      - Adicionar op��o customizada, integra��o com FUSION.

  @author Elvis Siqueira - TOTVS
  @since  08/01/2025 
/*/
//----------------------------------------------------------
User Function OM460MNU()

  ADD OPTION aRotina TITLE "Atualiza NF Fusion" ACTION "U_PFUSATUNF()" OPERATION 7 ACCESS 0

Return
