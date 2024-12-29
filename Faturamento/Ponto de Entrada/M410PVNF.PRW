#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} User Function M410PVNF
    Ponto-de-Entrada: M410PVNF - Geração de notas fiscais
    Executado antes da rotina de geração de NF's (MA410PVNFS()).
    @return
    (logico)
      Variavel logica, sendo:
      .T. (prossegue o processamento para a geração da NF.)
      .F. (impede o processamento.)
    @example
    @see (https://tdn.totvs.com/pages/releaseview.action?pageId=6784152)
    /*/

User Function M410PVNF()
Local lRet := .F.

   FWAlertWarning("Rotina desabilitada devido a geração de boleto online automaticamente.",;
                  "Rotina desabilitada!")

Return lRet
