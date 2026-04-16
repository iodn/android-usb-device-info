// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'IR Blaster';

  @override
  String get loading => 'A carregar…';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get failedToStart => 'Falha ao iniciar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get quickTilePower => 'Ligar';

  @override
  String get quickTileMute => 'Mudo';

  @override
  String get quickTileVolumeUp => 'Vol +';

  @override
  String get quickTileVolumeDown => 'Vol -';

  @override
  String get homeUsbPermissionRequiredMessage =>
      'Este telefone não tem IR integrado. Foi detetado um dongle IR USB, mas ainda não tem permissão.\n\nAceite o aviso USB para ativar o envio de IR.';

  @override
  String get homeUsbPermissionDeniedMessage =>
      'Este telefone não tem IR integrado. Foi detetado um dongle IR USB, mas a permissão USB foi negada.\n\nPeça-a novamente e aceite o aviso para ativar o IR.';

  @override
  String get homeUsbPermissionGrantedMessage =>
      'Este telefone não tem IR integrado. O dongle IR USB está autorizado, mas ainda não foi inicializado.';

  @override
  String get homeUsbOpenFailedMessage =>
      'Este telefone não tem IR integrado. O dongle IR USB foi detetado e autorizado, mas não pôde ser iniciado.\n\nVolte a ligá-lo e tente novamente.';

  @override
  String get homeUsbReadyMessage => 'Este telefone não tem IR integrado.';

  @override
  String get homeUsbNoDeviceMessage =>
      'Este telefone não tem IR integrado e não há nenhum dongle IR USB compatível ligado.\n\nAinda pode criar, importar e gerir comandos, mas para emitir IR tem de usar um dongle USB compatível ou um adaptador de áudio para IR.';

  @override
  String get homeUsbOptionPlugIn =>
      'Ligue um dongle IR USB compatível e aceite a permissão.';

  @override
  String get homeUsbOptionReady => 'Pronto a usar.';

  @override
  String get homeUsbOptionPermissionRequired => 'Ligado. Permissão necessária.';

  @override
  String get homeUsbOptionPermissionDenied =>
      'Permissão negada. Peça novamente.';

  @override
  String get homeUsbOptionPermissionGranted =>
      'Autorizado. A iniciar o dongle.';

  @override
  String get homeUsbOptionOpenFailed =>
      'Autorizado, mas a inicialização falhou.';

  @override
  String get homeHardwareBannerNoInternal =>
      'Este telefone não tem IR integrado. Ligue um dongle IR USB ou ative o modo Áudio em Definições.';

  @override
  String get homeHardwareBannerPermissionRequired =>
      'Dongle USB detetado. É necessária permissão para enviar IR.';

  @override
  String get homeHardwareBannerPermissionDenied =>
      'A permissão USB foi negada. Peça novamente para enviar IR.';

  @override
  String get homeHardwareBannerPermissionGranted =>
      'Dongle USB autorizado. A aguardar inicialização.';

  @override
  String get homeHardwareBannerOpenFailed =>
      'Dongle USB autorizado, mas a inicialização falhou.';

  @override
  String get homeHardwareBannerReady => 'USB está listo.';

  @override
  String get homeHardwareRequiredTitle =>
      'É necessário hardware IR para enviar comandos';

  @override
  String get homeUsbDongleRecommended => 'Dongle IR USB (recomendado)';

  @override
  String get homeAudioAdapterAlternative =>
      'Adaptador IR por áudio (alternativa)';

  @override
  String get homeAudioAdapterDescription =>
      'Definições → Emissor IR → Áudio (1 LED / 2 LED). Requer um adaptador de áudio para IR.';

  @override
  String get close => 'Fechar';

  @override
  String get homeChooseTransmitter => 'Escolha um emissor';

  @override
  String get openSettings => 'Abrir Definições';

  @override
  String get homeUsbPermissionSentApprove =>
      'Pedido de permissão USB enviado. Aceite o aviso para ativar o USB.';

  @override
  String get homeUsbDongleNotDetected =>
      'Nenhum dongle IR USB compatível foi detetado. Ligue-o e tente novamente.';

  @override
  String get homeUsbPermissionRequestFailed =>
      'Não foi possível pedir a permissão USB.';

  @override
  String get working => 'A processar…';

  @override
  String get requestUsbPermission => 'Pedir permissão USB';

  @override
  String get homeHardwareTip =>
      'Dica: ainda pode criar e ordenar comandos. O hardware só é necessário ao transmitir.';

  @override
  String get homeNoIrTransmitterTitle => 'Nenhum emissor IR disponível';

  @override
  String get homeHardwareRequiredBody =>
      'O IR Blaster pode criar e gerir comandos em qualquer telemóvel. Para enviar efetivamente comandos por infravermelhos, o seu dispositivo precisa de uma das opções de hardware abaixo.';

  @override
  String get homeCanStillUseWithoutHardware =>
      'Ainda pode criar, importar e organizar comandos neste momento.';

  @override
  String get homeWaysToUseIrBlaster => 'Formas de usar o IR Blaster';

  @override
  String get homeBuiltInIrOptionTitle => 'Telemóvel com IV integrado';

  @override
  String get homeBuiltInIrOptionSubtitle =>
      'Funciona em telemóveis compatíveis com emissor IV integrado. Este telemóvel não inclui um.';

  @override
  String get homeBuiltInIrUnavailable => 'Não disponível neste telemóvel';

  @override
  String get homeUsbFamilyTiqiaaZaza => 'Tiqiaa / ZaZa';

  @override
  String get homeUsbFamilyElkSmart => 'ElkSmart';

  @override
  String get homeAudioAccessoryLabel => 'Adaptador de áudio de 3,5 mm';

  @override
  String get homeContinueWithoutHardware => 'Continuar sem hardware';

  @override
  String get homeHowItWorks => 'Como funciona';

  @override
  String get settingsNavLabel => 'Definições';

  @override
  String get dismiss => 'Descartar';

  @override
  String get remotesNavLabel => 'Comandos';

  @override
  String get macrosNavLabel => 'Macros';

  @override
  String get signalTesterNavLabel => 'Probador IR';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get remoteNoIrEmitterTitle => 'Sem emissor IR';

  @override
  String get remoteNoIrEmitterMessage => 'Este dispositivo não tem emissor IR';

  @override
  String get remoteNoIrEmitterNeedsEmitter =>
      'Esta app precisa de um emissor IR para funcionar';

  @override
  String get remoteDismiss => 'Descartar';

  @override
  String get remoteClose => 'Fechar';

  @override
  String remoteFailedToSend(Object error) {
    return 'Falha ao enviar IR: $error';
  }

  @override
  String remoteFailedToStartLoop(Object error) {
    return 'Não foi possível iniciar o ciclo: $error';
  }

  @override
  String remoteLoopStoppedFailed(Object error) {
    return 'Ciclo parado, envio falhado: $error';
  }

  @override
  String remoteLoopingHint(Object title) {
    return 'A repetir \"$title\". Toque em Parar acima para parar.';
  }

  @override
  String get remoteLoopStopped => 'Ciclo detenido.';

  @override
  String get remoteUpdatedNotFound =>
      'O comando foi atualizado no ecrã. Não foi encontrado na lista guardada.';

  @override
  String remoteUpdatedNamed(Object name) {
    return 'Foi atualizado \"$name\".';
  }

  @override
  String remoteDeleteFailed(Object error) {
    return 'Falha ao eliminar: $error';
  }

  @override
  String get remoteNotFoundSavedList =>
      'Não foi encontrado o comando na lista guardada.';

  @override
  String remoteDeletedNamed(Object name) {
    return 'Foi eliminado \"$name\".';
  }

  @override
  String get buttonFallbackTitle => 'Botão';

  @override
  String get imageFallbackTitle => 'Imagem';

  @override
  String get noBrowserAvailable => 'Nenhum navegador disponível';

  @override
  String failedToOpen(Object error) {
    return 'Não foi possível abrir: $error';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get settingsRestoreDemoTitle => 'Restaurar comandos de demonstração?';

  @override
  String get settingsRestoreDemoMessage =>
      'Isto vai substituir os seus comandos atuais pelos comandos de demonstração integrados. Recomenda-se exportar uma cópia se quiser manter a lista atual.';

  @override
  String get settingsRestoreDemoConfirm => 'Restaurar demo';

  @override
  String get settingsDemoRemotesRestored =>
      'Comandos de demonstração restaurados.';

  @override
  String get settingsDeleteAllRemotesTitle => 'Eliminar todos os comandos?';

  @override
  String get settingsDeleteAllRemotesMessage =>
      'Isto remove todos os comandos deste dispositivo. Esta ação não pode ser anulada.';

  @override
  String get settingsDeleteAllConfirm => 'Eliminar tudo';

  @override
  String get settingsAllRemotesDeleted => 'Todos os comandos foram eliminados.';

  @override
  String get themeAuto => 'Tema auto';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeDescAuto => 'Segue as definições do dispositivo';

  @override
  String get themeDescLight => 'Sempre claro e nítido';

  @override
  String get themeDescDark => 'Descansa a vista';

  @override
  String get themeHintAuto =>
      'O tema muda apenas quando alterna entre modo claro e escuro no dispositivo';

  @override
  String get themeHintLight =>
      'Perfeito para usar de dia e em locais bem iluminados';

  @override
  String get themeHintDark =>
      'Reduz a fadiga visual com pouca luz e poupa bateria em ecrãs OLED';

  @override
  String get supportDevelopmentTitle => 'Apoyar desarrollo';

  @override
  String get supportDevelopmentSubtitle =>
      'Ajuda a manter o IR Blaster e a sua compatibilidade de hardware';

  @override
  String get supportDevelopmentBody =>
      'Sem anúncios, sem rastreio nem funções bloqueadas. O seu apoio financia protocolos, suporte USB e melhor compatibilidade entre dispositivos.';

  @override
  String get donate => 'Donar';

  @override
  String get starRepo => 'Dar estrella';

  @override
  String get repositoryLinkCopied => 'Enlace do repositorio copiado';

  @override
  String get supportPillLocalOnly => 'Apenas local';

  @override
  String get supportPillNoTracking => 'Sem rastreio';

  @override
  String get supportPillHardwareAware => 'Consciente do hardware';

  @override
  String get supportPillOpenSource => 'Código aberto';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get appearanceSubtitle => 'Personalize a experiência visual';

  @override
  String get localizationTitle => 'Idioma';

  @override
  String get localizationSubtitle =>
      'Idioma da app e comportamento da tradução';

  @override
  String localizationAutoUsing(Object language) {
    return 'Auto: usando $language';
  }

  @override
  String get localizationAutoDescription =>
      'A app segue o idioma do dispositivo quando possível.';

  @override
  String get localizationManualDescription =>
      'O idioma da app foi definido manualmente.';

  @override
  String get useSystemLanguageTitle => 'Usar idioma do sistema';

  @override
  String useSystemLanguageEnabled(Object language) {
    return 'A seguir o idioma do dispositivo: $language';
  }

  @override
  String get useSystemLanguageDisabled =>
      'Usa o idioma escolhido abaixo em vez do predefinido do dispositivo.';

  @override
  String get chooseAppLanguage => 'Escolher idioma da app';

  @override
  String get languagePickerDisabledHint =>
      'Desative o idioma do sistema para escolher um manualmente.';

  @override
  String get searchLanguages => 'Pesquisar idiomas';

  @override
  String get noLanguagesFound => 'Nenhum idioma correspondente';

  @override
  String get localizationHint =>
      'Se o idioma do sistema estiver ativo, a app segue a configuração regional do dispositivo e usa inglês se faltar uma tradução. Desative-o para fixar um idioma.';

  @override
  String get appLanguageTitle => 'Idioma da app';

  @override
  String get appLanguageHint =>
      'Auto segue o idioma do dispositivo. Escolha aqui inglês ou francês para forçá-lo apenas na app.';

  @override
  String get languageAuto => 'Auto (sistema)';

  @override
  String get languageAutoDescription =>
      'Seguir o idioma do dispositivo automaticamente';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageEnglishDescription => 'Forçar a app a usar sempre inglês';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageFrenchDescription => 'Forçar a app a usar sempre francês';

  @override
  String get languageAutoShort => 'Auto';

  @override
  String get languageEnglishShort => 'Inglês';

  @override
  String get languageFrenchShort => 'Francês';

  @override
  String get useDynamicColors => 'Usar colores dinámicos';

  @override
  String get themeChoiceAuto => 'Auto';

  @override
  String get themeChoiceLight => 'Claro';

  @override
  String get themeChoiceDark => 'Escuro';

  @override
  String get irTransmitterTitle => 'Emissor IR';

  @override
  String get irTransmitterSubtitle => 'Escolha que hardware envia comandos IR';

  @override
  String get learningModeEntryTitle => 'Modo de aprendizagem';

  @override
  String get learningModeEntrySubtitle =>
      'Capture um botão de um controle remoto físico passo a passo';

  @override
  String get learningModeTitle => 'Modo de aprendizagem';

  @override
  String get learningModeHeroTitle => 'Aprenda um botão remoto de forma limpa';

  @override
  String get learningModeHeroSubtitle =>
      'Configure seu receptor, prepare o controle remoto original, capture um comando e revise-o antes de salvá-lo em um controle remoto.';

  @override
  String get learningModeReadyBadge => 'Receptor pronto';

  @override
  String get learningModeNeedsPermissionBadge => 'Permissão USB necessária';

  @override
  String get learningModeSetupBadge => 'Configuração do receptor necessária';

  @override
  String get learningModeNoReceiverBadge => 'Nenhum receptor de aprendizagem';

  @override
  String get learningModeCheckingBadge => 'Verificando hardware';

  @override
  String get learningModeFourStepFlow => 'Fluxo guiado em 4 etapas';

  @override
  String get learningModeSaveAnywhereBadge => 'Revise antes de salvar';

  @override
  String get learningModeGuideTitle => 'Escolha onde a captura deve acontecer';

  @override
  String get learningModeStepHardwareShort => 'Hardware';

  @override
  String get learningModeStepPrepareShort => 'Preparar';

  @override
  String get learningModeStepCaptureShort => 'Capturar';

  @override
  String get learningModeStepReviewShort => 'Análise';

  @override
  String get learningModeStepHardwareTitle =>
      'Verifique o hardware do receptor';

  @override
  String get learningModeStepHardwareSubtitle =>
      'Certifique-se de que um receptor de aprendizagem compatível esteja conectado e autorizado antes de começar.';

  @override
  String get learningModeCurrentSenderLabel => 'Transmissor atual';

  @override
  String get learningModeReceiverStatusLabel => 'Status de aprendizagem';

  @override
  String get learningModeCheckingHardwareBody =>
      'Verificando o estado do transmissor disponível e do receptor USB.';

  @override
  String get learningModeHardwareReadyBody =>
      'Um dongle USB IR é conectado e inicializado. Este é o lugar certo para iniciar o fluxo de aprendizagem assim que a fiação de captura estiver conectada.';

  @override
  String get learningModeHardwarePermissionBody =>
      'Um dongle USB está presente, mas a permissão do Android ainda o bloqueia. Conceda permissão USB na seção do transmissor antes de aprender.';

  @override
  String get learningModeHardwareSetupBody =>
      'Um dongle foi parcialmente detectado, mas ainda precisa ser configurado ou reconectado antes que o aprendizado possa começar de forma confiável.';

  @override
  String get learningModeHardwareNoReceiverBody =>
      'Nenhum hardware receptor compatível está disponível atualmente. O modo de aprendizagem destina-se a dongles externos suportados com capacidade de recepção.';

  @override
  String get learningModeRefreshHardware => 'Atualizar status do hardware';

  @override
  String get learningModeHardwareTipTitle => 'Melhor colocação';

  @override
  String get learningModeHardwareTipBody =>
      'O Modo de Aprendizagem reside no Transmissor IR porque depende da disponibilidade do hardware e é usado com menos frequência do que o envio de controles remotos.';

  @override
  String get learningModeStepPrepareTitle =>
      'Prepare o controle remoto original';

  @override
  String get learningModeStepPrepareSubtitle =>
      'Decida o que você está aprendendo e mantenha o controle remoto original estável e próximo ao receptor.';

  @override
  String get learningModeButtonNameLabel => 'Nome do botão';

  @override
  String get learningModeButtonNameHint =>
      'Por exemplo: HDMI 1, Alimentação, Menu';

  @override
  String get learningModeSinglePress => 'Pressão única';

  @override
  String get learningModeHoldButton => 'Botão segurar';

  @override
  String get learningModePreparationChecklistTitle => 'Antes de capturar';

  @override
  String get learningModePreparationItemDistance =>
      'Mantenha o controle remoto original a cerca de 2 a 5 cm do receptor.';

  @override
  String get learningModePreparationItemOneButton =>
      'Aprenda um botão de cada vez e use primeiro um toque curto e limpo.';

  @override
  String get learningModePreparationItemStill =>
      'Mantenha ambos os dispositivos estáveis ​​para evitar capturas ruidosas ou parciais.';

  @override
  String get learningModeStepCaptureTitle => 'Capture o sinal';

  @override
  String get learningModeStepCaptureSubtitle =>
      'Ouça um único comando e bloqueie o resultado antes de revisá-lo.';

  @override
  String get learningModeCaptureReadyTitle => 'Pronto para ouvir';

  @override
  String get learningModeCaptureReadyBody =>
      'O estado do seu hardware parece bom. O back-end de captura será conectado a esta etapa a seguir.';

  @override
  String get learningModeCaptureBlockedTitle =>
      'Hardware ainda não está pronto';

  @override
  String get learningModeCaptureBlockedBody =>
      'Você ainda pode revisar o fluxo agora, mas a captura deverá aguardar até que o receptor esteja pronto.';

  @override
  String get learningModeStartListening => 'Comece a ouvir';

  @override
  String get learningModeCaptureStubTitle =>
      'O back-end de captura vem a seguir';

  @override
  String get learningModeCaptureStubBody =>
      'Essa tela é totalmente estruturada primeiro para que o fluxo de captura final possa ser conectado aos estados reais do hardware, em vez de ser anexado posteriormente.';

  @override
  String get learningModeCaptureStubMessage =>
      'A captura de aprendizagem ainda não está conectada. Esta tela estrutura o fluxo completo primeiro.';

  @override
  String get learningModeUnnamedCapture => 'Captura sem nome';

  @override
  String get learningModeStatusCheckingTitle => 'Verificando o receptor';

  @override
  String get learningModeStatusNoReceiverTitle => 'Receptor não está pronto';

  @override
  String get learningModeStatusPermissionTitle => 'Permissão USB necessária';

  @override
  String get learningModeStatusSetupTitle =>
      'O receptor precisa de configuração';

  @override
  String get learningModeStatusReadyTitle => 'Pronto para aprender';

  @override
  String get learningModeStatusListeningTitle => 'Ouvindo um sinal';

  @override
  String get learningModeStatusCapturedTitle => 'Sinal capturado';

  @override
  String get learningModeStatusReadyBody =>
      'Dê um nome ao botão, aponte o controle remoto original para o receptor e comece a ouvir quando estiver pronto.';

  @override
  String get learningModeStatusListeningBody =>
      'Pressione o botão do controle remoto original agora. Depois que a captura for conectada, esse estado será bloqueado no próximo sinal limpo.';

  @override
  String learningModeStatusCapturedBody(Object buttonName) {
    return 'Uma visualização do sinal aprendido está pronta para $buttonName. Reproduza-o, confirme se funciona e salve-o em sua biblioteca.';
  }

  @override
  String get learningModeConnectReceiverTitle =>
      'Conecte um dongle de aprendizagem compatível';

  @override
  String get learningModeConnectReceiverBody =>
      'O modo de aprendizagem depende do hardware externo que pode receber IR. Depois que o receptor for detectado e autorizado, esta página se tornará um fluxo direto de escuta, teste e salvamento.';

  @override
  String get learningModeListenCardTitle => 'Ouça um botão';

  @override
  String get learningModeListenCardBody =>
      'Defina primeiro um rótulo, se desejar, depois comece a ouvir e pressione o botão no controle remoto original.';

  @override
  String get learningModeReadyToListenTitle => 'Pronto para ouvir';

  @override
  String get learningModeReadyToListenBody =>
      'Esta é a principal superfície de captura. Comece a ouvir apenas quando o controle remoto original estiver apontado e estável.';

  @override
  String get learningModeListeningNowTitle => 'Ouvindo agora';

  @override
  String get learningModeListeningNowBody =>
      'Pressione o botão do controle remoto original uma vez. Use a captura de visualização para percorrer o resto do andaime antes que o back-end de captura real seja conectado.';

  @override
  String get learningModePreviewCaptureAction => 'Visualizar sinal capturado';

  @override
  String get learningModeCapturedSummary => 'Visualização do sinal aprendido';

  @override
  String get learningModeResultActionsTitle => 'Teste e salve';

  @override
  String get learningModeResultActionsBody =>
      'Reproduza o sinal aprendido, verifique se o dispositivo alvo responde e salve-o como um botão reutilizável.';

  @override
  String get learningModeReplayAction => 'Repetir';

  @override
  String get learningModeReplayStubMessage =>
      'O replay ainda não está conectado. Esta é a estrutura da UI para o fluxo final de aprendizado, teste e salvamento.';

  @override
  String get learningModeSaveStubMessage =>
      'Salvar ainda não está conectado. A próxima etapa é conectar esta tela ao botão Criar e aos controles remotos existentes.';

  @override
  String get learningModeLearnAnotherAction => 'Aprenda outro botão';

  @override
  String get learningModeStepReviewTitle => 'Revise e salve';

  @override
  String get learningModeStepReviewSubtitle =>
      'Confirme o que foi aprendido e escolha onde ele deve ficar na sua biblioteca remota.';

  @override
  String get learningModeSaveToExistingRemote => 'Remoto existente';

  @override
  String get learningModeCreateNewRemote => 'Novo controle remoto';

  @override
  String get learningModeProtocolPreviewTitle => 'Visualização do protocolo';

  @override
  String get learningModeProtocolPreviewBody =>
      'Os detalhes do protocolo decodificado aparecerão aqui assim que o receptor capturar um pressionamento de botão limpo.';

  @override
  String get learningModeRawPreviewTitle => 'Reserva bruta';

  @override
  String get learningModeRawPreviewBody =>
      'Se a decodificação estiver incompleta, a captura de tempo bruto ainda estará disponível aqui para revisão e salvamento.';

  @override
  String get learningModeSaveCapture => 'Salvar captura';

  @override
  String get learningModeReviewTipTitle => 'Para onde isso irá a seguir';

  @override
  String get learningModeReviewTipBody =>
      'A próxima etapa de implementação deve conectar este painel de revisão ao botão Criar e aos controles remotos existentes para que o sinal aprendido caia diretamente em sua biblioteca.';

  @override
  String get learningModeFinishPreview => 'Concluir visualização';

  @override
  String get backAction => 'Back';

  @override
  String get interactionTitle => 'Interacción';

  @override
  String get interactionSubtitle => 'Resposta tátil e disposição do comando';

  @override
  String get hapticFeedbackTitle => 'Respuesta háptica';

  @override
  String get hapticFeedbackSubtitle => 'Vibrar ao tocar e ao executar ações';

  @override
  String get forceInAppVibrationTitle => 'Forçar vibração na aplicação';

  @override
  String get forceInAppVibrationSubtitle =>
      'Usar o vibrador diretamente mesmo que o feedback tátil do sistema esteja desligado';

  @override
  String get forceInAppVibrationWarning =>
      'Opção avançada. A aplicação pode vibrar mesmo quando o feedback tátil do Android está desativado globalmente.';

  @override
  String get forceInAppVibrationBlockedMasterWarning =>
      'Android system vibration is disabled. Force in-app vibration cannot override it on this device.';

  @override
  String get forceInAppVibrationNoVibratorWarning =>
      'This device reports no vibrator hardware, so in-app vibration cannot work.';

  @override
  String get intensity => 'Intensidad';

  @override
  String get intensityLight => 'Claro';

  @override
  String get intensityMedium => 'Media';

  @override
  String get intensityStrong => 'Fuerte';

  @override
  String get flipRemoteDefaultTitle => 'Inverter vista do comando por defecto';

  @override
  String get flipRemoteDefaultSubtitle =>
      'Abre os ecrãs do comando rodados 180° (para dongles USB montados em baixo).';

  @override
  String get remoteViewFlipped => 'A vista do comando vai abrir invertida.';

  @override
  String get remoteViewNormal => 'A vista do comando vai abrir normal.';

  @override
  String get backupTitle => 'Cópia';

  @override
  String get backupSubtitle => 'Importar/exportar comandos e macros';

  @override
  String get importBackup => 'Importar cópia';

  @override
  String get importBackupSubtitle =>
      'Importa cópias de comandos/macros ou ficheiros do Flipper Zero, LIRC ou IRPLUS';

  @override
  String get bulkImportFolder => 'Importar pasta';

  @override
  String get bulkImportFolderSubtitle =>
      'Importar vários comandos de uma pasta';

  @override
  String get exportBackup => 'Exportar cópia';

  @override
  String get exportBackupSubtitle =>
      'Guardar comandos + macros como un JSON en Descargas';

  @override
  String get restoreDemoRemotes => 'Restaurar comandos de demonstração';

  @override
  String get restoreDemoRemotesSubtitle =>
      'Substituir os comandos atuais pela demonstração integrada';

  @override
  String get deleteAllRemotes => 'Eliminar todos os comandos';

  @override
  String get deleteAllRemotesSubtitle =>
      'Eliminar todos os comandos deste dispositivo';

  @override
  String get backupTip =>
      'Dica: exporte uma cópia antes de grandes alterações. A importação aceita cópias completas, cópias JSON antigas de comandos e ficheiros .ir do Flipper Zero.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutSubtitle => 'Informação da app e detalhes de código aberto';

  @override
  String aboutAppNameWithCreator(Object creator) {
    return 'IR Blaster - $creator';
  }

  @override
  String versionLabel(Object version) {
    return 'Versión $version';
  }

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get viewOnGitHub => 'Ver en GitHub';

  @override
  String get repositoryUrlCopied => 'URL do repositorio copiada';

  @override
  String get reportIssue => 'Reportar problema';

  @override
  String get reportIssueSubtitle => 'Erros e pedidos de funcionalidades';

  @override
  String get issuesUrlCopied => 'URL de issues copiada';

  @override
  String get license => 'Licencia';

  @override
  String get openSourceLicense => 'Licencia de código aberto';

  @override
  String get licenseUrlCopied => 'URL da licença copiado';

  @override
  String get companyName => 'KaijinLab Inc.';

  @override
  String get visitWebsite => 'Visitar nuestro sitio web';

  @override
  String get companyUrlCopied => 'URL da empresa copiado';

  @override
  String get licenses => 'Licencias';

  @override
  String get openSourceLicenses => 'Licencias de código aberto';

  @override
  String byCreator(Object creator) {
    return 'por $creator';
  }

  @override
  String get deviceControlsTitle => 'Controlos do dispositivo';

  @override
  String get deviceControlsSubtitle =>
      'Mostrar botões favoritos na página de controlos do sistema';

  @override
  String get manageFavorites => 'Gerir favoritos';

  @override
  String get manageFavoritesSubtitle =>
      'Escolha que botões aparecem nos controlos do dispositivo';

  @override
  String get quickSettingsTitle => 'Definições rápidas';

  @override
  String get quickSettingsSubtitle =>
      'Adicionar mosaicos para atalhos de energia e volume';

  @override
  String get configureTiles => 'Configurar mosaicos';

  @override
  String get configureTilesSubtitle => 'Atribuir mosaicos a botões do comando';

  @override
  String get tvKillTitle => 'TVKill';

  @override
  String get tvKillSubtitle =>
      'Ciclo universal de energia para dispositivos próprios';

  @override
  String get openTvKill => 'Abrir TVKill';

  @override
  String get openTvKillSubtitle =>
      'Ciclar códigos de energia (use apenas em dispositivos seus)';

  @override
  String get failedToLoadTransmitterSettings =>
      'Falha ao carregar as definições do emissor.';

  @override
  String get usbStatusReady =>
      'O dongle USB está ligado e pronto para enviar IR.';

  @override
  String get usbStatusPermissionRequired =>
      'Dongle USB detetado. Peça permissão USB e aceite o aviso do sistema.';

  @override
  String get usbStatusPermissionDenied =>
      'Foi negada o permissão USB para o dongle ligado. Peça-a outra vez e aceite o aviso.';

  @override
  String get usbStatusPermissionGranted =>
      'A permissão USB foi concedida. O dongle ainda precisa de ser inicializado antes de poder enviar IR.';

  @override
  String get usbStatusOpenFailed =>
      'A permissão USB foi concedida, mas o dongle não pôde ser inicializado. Volte a ligá-lo e tente novamente.';

  @override
  String get usbStatusNoDevice =>
      'Não foi detetado un dongle IR USB compatível.';

  @override
  String get usbSelectPermissionRequired =>
      'Dongle USB detetado, mas não autorizado. Toque em \"Pedir permissão USB\".';

  @override
  String get usbSelectPermissionDenied =>
      'A permissão USB foi negada. Toque em \"Pedir permissão USB\" e aceite o aviso.';

  @override
  String get usbSelectPermissionGranted =>
      'A permissão USB foi concedida, mas o dongle ainda não foi inicializado. Tente voltar a ligá-lo.';

  @override
  String get usbSelectOpenFailed =>
      'A permissão USB foi concedida, mas o dongle não pôde ser inicializado. Volte a ligá-lo e tente novamente.';

  @override
  String get usbSelectNoDevice =>
      'Nenhum dongle IR USB compatível foi detetado. Ligue-o e depois toque em \"Pedir permissão USB\".';

  @override
  String get usbSelectReady => 'O dongle USB está pronto.';

  @override
  String get autoSwitchEnabledMessage =>
      'Mudança automática ativada: usa USB quando está ligado, caso contrário Interno.';

  @override
  String get autoSwitchDisabledMessage =>
      'Cambio automático desativedo: a seleção do emissor ahora es manual.';

  @override
  String get failedToUpdateAutoSwitch =>
      'Falha ao atualizar a definição de mudança automática.';

  @override
  String get failedToSwitchTransmitter => 'Falha ao mudar de emissor.';

  @override
  String get deviceHasNoInternalIr =>
      'Este dispositivo não tem emissor IR integrado.';

  @override
  String get audioModeEnabledMessage =>
      'Modo áudio ativado. Usa o volume multimedia ao máximo e un adaptador LED de áudio a IR.';

  @override
  String get usbPermissionRequestSent => 'Solicitud de permissão USB enviada.';

  @override
  String get usbPermissionRequestSentApprove =>
      'Pedido de permissão USB enviado. Aceite o aviso para ativar o USB.';

  @override
  String get usbAlreadyReady => 'O dongle USB já está inicializado e pronto.';

  @override
  String get failedToRequestUsbPermission =>
      'Não foi possível pedir a permissão USB.';

  @override
  String get transmitterHelpInternal =>
      'Usa o emissor IR integrado do telefone para enviar comandos.';

  @override
  String get transmitterHelpUsb =>
      'Usa un dongle IR USB (requiere permissão) para enviar comandos.';

  @override
  String get transmitterHelpAudio1 =>
      'Usa a saída de áudio (mono). Requiere un adaptador LED de áudio a IR e volume multimedia alto.';

  @override
  String get transmitterHelpAudio2 =>
      'Usa a saída de áudio (estéreo). Usa dos canales para un melhor control LED con adaptadores compatíveis.';

  @override
  String get transmitterInternal => 'IR interno';

  @override
  String get transmitterUsb => 'Dongle IR USB';

  @override
  String get transmitterAudio1 => 'Áudio (1 LED)';

  @override
  String get transmitterAudio2 => 'Áudio (2 LED)';

  @override
  String get failedToLoadTransmitterCapabilities =>
      'Falha ao carregar as capacidades do emissor.';

  @override
  String get selectedTransmitter => 'Emissor selecionado';

  @override
  String selectedTransmitterValue(Object effective, Object active) {
    return '$effective • Activo: $active';
  }

  @override
  String get refresh => 'Atualizar';

  @override
  String get autoSwitchTitle => 'Cambio auto';

  @override
  String get autoSwitchDisabledWhileAudio => 'Desativado ao usar modo Áudio';

  @override
  String get autoSwitchUsesUsbOtherwiseInternal =>
      'Usa USB quando está ligado, caso contrário Interno';

  @override
  String get unavailableOnThisDevice => 'Não disponible en este dispositivo';

  @override
  String get openOnUsbAttachTitle => 'Abrir ao ligar USB';

  @override
  String get openOnUsbAttachSubtitle =>
      'O Android pode sugerir abrir a app quando um dongle IR USB compatível é ligado.';

  @override
  String get openOnUsbAttachEnabledMessage =>
      'Vai sugerir abrir o IR Blaster quando um dongle USB compatível for ligado.';

  @override
  String get openOnUsbAttachDisabledMessage =>
      'Não vai sugerir abrir ao ligar USB.';

  @override
  String get failedToUpdateSetting => 'Falha ao atualizar a definição.';

  @override
  String get unnamedButton => 'Botão sem nome';

  @override
  String get iconFallback => 'Icono';

  @override
  String get remoteListReorderHint =>
      'Modo reordenar: mantenha premido e arraste uma cartão para moverla.';

  @override
  String get deleteRemoteTitle => 'Eliminar comando?';

  @override
  String deleteRemoteMessage(Object name) {
    return '\"$name\" será removido permanentemente. Esta ação não pode ser anulada.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get addToDeviceControlsTitle =>
      'Adicionar a Controlos do dispositivo?';

  @override
  String get addToDeviceControlsDescription =>
      'Acceso rápido en os controlos do sistema.';

  @override
  String get skip => 'Omitir';

  @override
  String get add => 'Adicionar';

  @override
  String get addedToDeviceControls => 'Añadido a Controlos do dispositivo.';

  @override
  String deletedRemoteUndoUnavailable(Object name) {
    return 'Foi eliminado \"$name\". Esta acción não pode ser anulado.';
  }

  @override
  String remoteLayoutSummary(int count, Object layout) {
    return '$count botão(es) · $layout';
  }

  @override
  String get layoutComfort => 'Cómodo';

  @override
  String get layoutCompact => 'Compacto';

  @override
  String get open => 'Abrir';

  @override
  String get useThisRemote => 'Usar este comando';

  @override
  String get edit => 'Editar';

  @override
  String get editRemoteSubtitle => 'Renombrar e editar botões';

  @override
  String get thisCannotBeUndone => 'Isto não pode ser anulado';

  @override
  String get searchRemotes => 'Pesquisar comandos';

  @override
  String get reorderRemotes => 'Reordenar comandos';

  @override
  String get addRemote => 'Adicionar comando';

  @override
  String get more => 'Mais';

  @override
  String get reorderMode => 'Modo reordenar';

  @override
  String remoteButtonCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count buttons',
      one: '$count button',
    );
    return '$_temp0';
  }

  @override
  String get noRemotesYet => 'Ainda não há comandos';

  @override
  String get noRemotesDescription =>
      'Crea un comando para empezar a enviar códigos IR.';

  @override
  String get noRemotesNextStep =>
      'Seguinte passo: toque em Adicionar comando e depois adicione os seus primeiros botões.';

  @override
  String get actions => 'Acciones';

  @override
  String get macrosTitle => 'Macros';

  @override
  String get help => 'Ajuda';

  @override
  String get createMacro => 'Criar macro';

  @override
  String get timedMacrosTitle => 'Macros temporizadas';

  @override
  String get timedMacrosSubtitle =>
      'Automatiza secuencias de comandos IR con temporización precisa';

  @override
  String get timedMacrosNextStep =>
      'Seguinte passo: toque em Criar a sua primeira macro, escolha um comando e depois adicione comandos e pausas.';

  @override
  String get macroFeatureToysTitle => 'Perfecto para brinquedos interactivos';

  @override
  String get macroFeatureToysDescription =>
      'Controla dispositivos como perros robô i-cybie, robôs i-sobot e otros brinquedos que precisan tiempo entre comandos para procesar acciones.';

  @override
  String get macroFeatureTimingTitle => 'Control preciso do tiempo';

  @override
  String get macroFeatureTimingDescription =>
      'Adicione pausas entre comandos (de 250 ms a duraciones personalizadas) para que o seu dispositivo responda antes de a seguinte acción.';

  @override
  String get macroFeatureManualTitle => 'Passos con continuación manual';

  @override
  String get macroFeatureManualDescription =>
      'Pausa a execução e espera o seu confirmación quando a animación varía o precisas confirmación visual.';

  @override
  String get exampleUseCase => 'Ejemplo de uso';

  @override
  String get macroExampleText =>
      'Modo avanzado de i-cybie:\n1. Enviar comando \"Mode\"\n2. Aguardar 1000 ms (el juguete procesa)\n3. Enviar \"Action 1\"\n4. Aguardar 1000 ms\n5. Enviar \"Action 2\"\n…y así sucesivamente de forma automática.';

  @override
  String get createFirstMacro => 'Crea o seu primeira macro';

  @override
  String get noRemote => 'Sem comando';

  @override
  String macroStepCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String get aboutTimedMacros => 'Sobre as macros temporizadas';

  @override
  String get aboutTimedMacrosDescription =>
      'As macros temporizadas permitem automatizar sequências de comandos IR com pausas precisas entre cada passo.';

  @override
  String get sendCommand => 'Enviar comando';

  @override
  String get sendCommandDescription =>
      'Transmite un comando IR de o seu comando.';

  @override
  String get delay => 'Pausa';

  @override
  String get delayDescription =>
      'Espera uma duración indicada (p. ej. 1000 ms) antes do seguinte passo.';

  @override
  String get manualContinue => 'Continuación manual';

  @override
  String get manualContinueDescription =>
      'Pausa a execução hasta que toques Continuar (útil para animaciones de duración variable).';

  @override
  String get gotIt => 'Entendido';

  @override
  String get failedToSaveMacros => 'Falha ao guardar macros.';

  @override
  String deletedMacroNamed(Object name) {
    return 'Foi eliminado \"$name\".';
  }

  @override
  String get undo => 'Anular';

  @override
  String get failedToRestoreMacro => 'Falha ao restaurar a macro.';

  @override
  String get deleteMacroTitle => 'Eliminar macro?';

  @override
  String get deleteMacroMessage => 'Pode anular isto desde o próximo mensaje.';

  @override
  String get noRemotesAvailable => 'Ainda não há comandos disponibles.';

  @override
  String remoteButtonCountSummary(int count) {
    return '$count botão(es)';
  }

  @override
  String get remoteOrientationFlippedTooltip =>
      'Orientação: invertida (toque para normal)';

  @override
  String get remoteOrientationNormalTooltip =>
      'Orientação: normal (toque para inverter)';

  @override
  String get stopLoop => 'Parar ciclo';

  @override
  String get reorderButtons => 'Reordenar botões';

  @override
  String get remoteReorderHint =>
      'Modo reordenar: mantenha premido e arraste un botão para moverlo.';

  @override
  String get manageRemote => 'Gerir comando';

  @override
  String get remoteNoButtons => 'Não há botões en este comando';

  @override
  String get remoteNoButtonsDescription =>
      'Usa \"Editar comando\" para adicionar o configurar botões.';

  @override
  String get editRemote => 'Editar comando';

  @override
  String get editRemoteActionsSubtitle =>
      'Renombrar, reordenar e editar botões';

  @override
  String remoteUpdatedNamedButton(Object name) {
    return 'Foi atualizado \"$name\".';
  }

  @override
  String buttonAddedNamed(Object name) {
    return 'Foi adicionado \"$name\".';
  }

  @override
  String get buttonDuplicated => 'Botão duplicado.';

  @override
  String get loopRunningForButton => 'O ciclo está ativo para este botão.';

  @override
  String get loopTip => 'Dica: usa Ciclo para repetir hasta detenerlo.';

  @override
  String get loopingBadge => 'Looping';

  @override
  String get codeCopied => 'Código copiado.';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get startLoop => 'Iniciar ciclo';

  @override
  String get editButtonSubtitle =>
      'Modificar etiqueta, código, protocolo e frecuencia';

  @override
  String get newButton => 'Novo botão';

  @override
  String get newButtonSubtitle => 'Criar um novo botão depois deste';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get duplicateButtonSubtitle => 'Criar uma cópia deste botão';

  @override
  String get removeFromDeviceControls => 'Remover de Controlos do dispositivo';

  @override
  String get addToDeviceControls => 'Adicionar a Controlos do dispositivo';

  @override
  String get deviceControlsButtonSubtitle =>
      'Muestra este botão en os controlos do dispositivo do sistema';

  @override
  String get removedFromDeviceControls =>
      'Quitado de Controlos do dispositivo.';

  @override
  String get pinQuickTile => 'Fixar nos favoritos dos mosaicos rápidos';

  @override
  String get unpinQuickTile => 'Remover dos favoritos dos mosaicos rápidos';

  @override
  String get quickTileButtonSubtitle =>
      'Mostra este botão acima do seletor de mosaicos';

  @override
  String get removedFromQuickTileFavorites =>
      'Removido dos favoritos dos mosaicos rápidos.';

  @override
  String get pinnedToQuickTileFavorites =>
      'Fixado nos favoritos dos mosaicos rápidos.';

  @override
  String get duplicateAndEdit => 'Duplicar e editar';

  @override
  String get duplicateAndEditSubtitle =>
      'Criar uma cópia e editá-la de imediato';

  @override
  String get done => 'Concluído';

  @override
  String get run => 'Executar';

  @override
  String get untitledRemote => 'Comando sem título';

  @override
  String get createRemoteTitle => 'Criar comando';

  @override
  String get editRemoteTitle => 'Editar comando';

  @override
  String get removeButtonTitle => 'Remover botão?';

  @override
  String get imageButtonRemovedMessage => 'Este botão de imagem será removido.';

  @override
  String namedButtonRemovedMessage(Object name) {
    return '\"$name\" será removido.';
  }

  @override
  String get remove => 'Remover';

  @override
  String importedButtonCount(int count) {
    return 'Foram importados $count botão(es).';
  }

  @override
  String importedButtonsFromExistingRemotes(int count) {
    return 'Foram importados $count botão(es) desde comandos existentes.';
  }

  @override
  String get editButtonSettingsSubtitle =>
      'Cambiar etiqueta, sinal e definições avanzados';

  @override
  String get createButtonCopySubtitle => 'Criar uma cópia deste botão';

  @override
  String get duplicateAndEditButtonSubtitle =>
      'Criar uma cópia e editá-la de imediato';

  @override
  String get undoAvailableInNextSnackbar =>
      'Pode deshacerlo desde o próximo mensaje';

  @override
  String get buttonRemoved => 'Botão quitado.';

  @override
  String get remoteNameCannotBeEmpty =>
      'O nome do comando não pode estar vazio.';

  @override
  String get saveRemote => 'Guardar comando';

  @override
  String get remoteName => 'Nome do comando';

  @override
  String get remoteNameHint => 'p. ej., TV, aire acondicionado, tira LED';

  @override
  String get remoteNameHelper =>
      'Este nome aparece en o seu lista de comandos.';

  @override
  String get layoutStyle => 'Estilo de diseño';

  @override
  String get layoutWideDescription =>
      'Ancho: botões de 2 columnas con detalhes extra (recomendado).';

  @override
  String get layoutCompactDescription =>
      'Compacto: grelha clásica 4× (apenas iconos/texto).';

  @override
  String get importFromRemotes => 'Importar desde comandos';

  @override
  String get importFromDatabase => 'Importar de BD';

  @override
  String get addButton => 'Adicionar botão';

  @override
  String get noButtonsYet => 'Ainda não há botões';

  @override
  String get createRemoteEmptyStateDescription =>
      'Adicione o seu primeiro botão e luego mantenha premido para editar o remover.';

  @override
  String get createButtonTitle => 'Criar botão';

  @override
  String get editButtonTitle => 'Editar botão';

  @override
  String failedToLoadProtocols(Object error) {
    return 'Falha ao carregar protocolos: $error';
  }

  @override
  String failedToLoadDatabaseKeys(Object error) {
    return 'Falha ao carregar chaves da base de dados: $error';
  }

  @override
  String get presetPower => 'Enc.';

  @override
  String get presetVolume => 'Volume';

  @override
  String get presetChannel => 'Canal';

  @override
  String get presetNavigation => 'Navegación';

  @override
  String get all => 'Todos';

  @override
  String get completeRequiredFieldsToSave =>
      'Completa os campos obrigatórios para guardar';

  @override
  String get buttonLabelStepTitle => 'Etiqueta do botão';

  @override
  String get buttonLabelStepSubtitle =>
      'Escolha uma imagem, un icono o escreva uma etiqueta.';

  @override
  String get buttonColorStepTitle => 'Cor do botão';

  @override
  String get buttonColorStepSubtitle =>
      'Escolha un cor de fondo para este botão.';

  @override
  String get selectColor => 'Selecione cor:';

  @override
  String get noImageSelected => 'Não há imagem selecionada';

  @override
  String get gallery => 'Galería';

  @override
  String get builtIn => 'Integrado';

  @override
  String get removeImage => 'Remover imagem';

  @override
  String get requiredSelectImageOrSwitch =>
      'Obligatorio: selecione uma imagem, escolha un icono o cambia a Texto.';

  @override
  String get iconSelected => 'Icono selecionado';

  @override
  String get noIconSelected => 'Não há icono selecionado';

  @override
  String get chooseIcon => 'Escolher icono';

  @override
  String get removeIcon => 'Remover icono';

  @override
  String get requiredSelectIconOrSwitch =>
      'Obligatorio: selecione un icono o cambia a Imagem/Texto.';

  @override
  String get buttonText => 'Texto do botão';

  @override
  String get buttonTextHint => 'p. ej., Enc., Volume +, HDMI 1';

  @override
  String get buttonTextHelper => 'Este texto aparecerá en o botão.';

  @override
  String get requiredEnterButtonLabel => 'Obligatorio: introduza uma etiqueta.';

  @override
  String get defaultColorName => 'Predeterminado';

  @override
  String get newRemoteCreatedFromLastHit =>
      'Foi criado un comando novo con un botão do último acierto.';

  @override
  String get selectRemote => 'Selecionar comando';

  @override
  String remoteNumber(Object id) {
    return 'Comando n.º $id';
  }

  @override
  String get newRemoteCreated => 'Comando novo criado.';

  @override
  String get failedToCreateRemote => 'Falha ao criar o comando.';

  @override
  String get newRemoteEllipsis => 'Novo comando…';

  @override
  String addedToRemoteNamed(Object name) {
    return 'Añadido a $name.';
  }

  @override
  String get failedToAddToRemote => 'Falha ao adicionar ao comando.';

  @override
  String get newRemoteDefaultName => 'Novo comando';

  @override
  String jumpedToOffsetPaused(int offset) {
    return 'Saltó ao deslocação $offset. En pausa, pulsa Retomar para seguir.';
  }

  @override
  String get sent => 'Enviado.';

  @override
  String failedToSend(Object error) {
    return 'Falha ao enviar: $error';
  }

  @override
  String get copiedProtocolCode => 'Copiado (protocolo:código).';

  @override
  String get savedToResults => 'Guardado en Resultados.';

  @override
  String invalidCodeForProtocol(Object error) {
    return 'Código inválido para o protocolo: $error';
  }

  @override
  String get copiedCurrentCandidate => 'Candidato atual copiado.';

  @override
  String get jumpToOffset => 'Saltar ao deslocação';

  @override
  String get jumpToBruteCursor => 'Saltar ao cursor de força bruta';

  @override
  String get jump => 'Saltar';

  @override
  String jumpedToCursorPaused(Object cursor) {
    return 'Saltó ao cursor 0x$cursor. En pausa, pulsa Retomar para seguir.';
  }

  @override
  String get irSignalTester => 'Probador de sinal IR';

  @override
  String get stop => 'Parar';

  @override
  String get selectButton => 'Selecionar botão';

  @override
  String get buttonNotFoundInRemotes => 'Botão não encontrado nos comandos.';

  @override
  String sentNamed(Object name) {
    return 'Foi enviado \"$name\".';
  }

  @override
  String sendFailed(Object error) {
    return 'Envio falhado: $error';
  }

  @override
  String get noFavoritesYet => 'Ainda não há favoritos';

  @override
  String get deviceControlsEmptyHint =>
      'Mantenha premido un botão do comando e selecione \"Adicionar a Controlos do dispositivo\".';

  @override
  String get sendTest => 'Enviar teste';

  @override
  String get testSendCompleted => 'Teste de envio concluída.';

  @override
  String testSendFailed(Object error) {
    return 'Falha no envio de teste: $error';
  }

  @override
  String removedNamed(Object name) {
    return 'Foi removido \"$name\".';
  }

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get selectBrand => 'Selecionar marca';

  @override
  String get searchBrand => 'Pesquisar marca…';

  @override
  String get selectModel => 'Selecionar modelo';

  @override
  String get searchModel => 'Pesquisar modelo…';

  @override
  String get unnamedKey => 'Tecla sem nome';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get emDash => '-';

  @override
  String get searchCommands => 'Pesquisar comandos';

  @override
  String get noMatchingCommands => 'Ainda não há comandos correspondentes';

  @override
  String get quickTileFavoritesTitle => 'Favoritos dos mosaicos rápidos';

  @override
  String changeMappingForTile(Object tileLabel) {
    return 'Cambiar asignación do mosaico $tileLabel';
  }

  @override
  String get pickDifferentButton => 'Escolha un botão distinto';

  @override
  String get browseAllRemotesEllipsis => 'Explorar todos os comandos…';

  @override
  String get invalidMacroFileFormat =>
      'Formato de ficheiro de macro não válido.';

  @override
  String get failedToParseMacroFile =>
      'Não se pudo analizar o ficheiro de macro.';

  @override
  String get deviceCodeLabel => 'Código de dispositivo';

  @override
  String get commandLabel => 'Comando';

  @override
  String get editButtonCodeTitle => 'Editar código do botão';

  @override
  String get thisRemoteHasNoButtons => 'Este comando não tem botões.';

  @override
  String get selectCommand => 'Selecionar comando';

  @override
  String get databaseModeAutofillHint =>
      'El modo Base de dados completa o Passo 2 por ti (marca + modelo + protocolo). Tras importar uma tecla, pode ajustar tudo en Manual.';

  @override
  String get test => 'Teste';

  @override
  String get allSelectedButtonsWereDuplicates =>
      'Todos os botões elegidos eran duplicados.';

  @override
  String get noButtonsImported => 'Não se importó nenhum botão.';

  @override
  String importedButtonsSkippedDuplicates(int addedCount, int skippedCount) {
    return 'Foram importados $addedCount botão(es). Se omitieron $skippedCount duplicado(s).';
  }

  @override
  String get importAllMatchingTitle =>
      'Importar todos os botões correspondentes?';

  @override
  String get noMatchingKeysFound =>
      'Não se encontraron teclas correspondentes.';

  @override
  String importAllMatchingMessage(int count) {
    return 'Isto importará hasta $count teclas correspondentes de a seleção atual de a base de dados.';
  }

  @override
  String get importAll => 'Importar tudo';

  @override
  String get importingButtons => 'Importando botões…';

  @override
  String get allMatchingButtonsWereDuplicates =>
      'Todos os botões correspondentes eran duplicados.';

  @override
  String get quickPresets => 'Definições rápidas';

  @override
  String get selectDeviceFirst => 'Selecione primeiroo un dispositivo';

  @override
  String get searchByLabelOrHex => 'Pesquisar por etiqueta o hex';

  @override
  String optionalRefinePresetKeys(Object preset) {
    return 'Opcional: afina as teclas predefinidas de $preset';
  }

  @override
  String get selectBrandModelProtocolFirst =>
      'Selecione primeiroo marca, modelo e protocolo.';

  @override
  String get importFromDatabaseTitle => 'Importar de a base de dados';

  @override
  String get importFromDatabaseSubtitle =>
      'Escolha un dispositivo, carga as teclas correspondentes e luego importa os botões selecionados.';

  @override
  String get deviceAndFilters => 'Dispositivo e filtros';

  @override
  String loadedCount(int count) {
    return '$count cargados';
  }

  @override
  String get hideFilters => 'Ocultar filtros';

  @override
  String get showFilters => 'Mostrar filtros';

  @override
  String get noProtocolFoundForBrandModel =>
      'Não se encontró un protocolo para esta marca e modelo.';

  @override
  String get protocolAutoDetected => 'Protocolo';

  @override
  String get protocolAutoDetectedHelper =>
      'Detetado automaticamente desde a base de dados. Pode cambiarlo antes de importar.';

  @override
  String get selectBrandModelToLoadKeys =>
      'Selecione uma marca, modelo e protocolo para carregar teclas.';

  @override
  String get noKeysFound => 'Não se encontraron teclas.';

  @override
  String noKeysFoundForSearch(Object query) {
    return 'Não se encontraron teclas para \"$query\".';
  }

  @override
  String get skipDuplicates => 'Omitir duplicados';

  @override
  String get skipDuplicatesSubtitle =>
      'Não importes botões que já existan en este comando.';

  @override
  String get importSelected => 'Importar selecionados';

  @override
  String get noMacrosToExport => 'Não há macros para exporter.';

  @override
  String get macrosExportedToDownloads => 'Macros exportedas a Descargas.';

  @override
  String get failedToExportMacros => 'Não se pudieron exporter as macros.';

  @override
  String get failedToReadFile => 'Não se pudo leer o ficheiro.';

  @override
  String get importFromExistingRemotesTitle =>
      'Importar desde comandos existentes';

  @override
  String selectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String get noOtherRemotesWithButtons =>
      'Não se encontraron otros comandos con botões.';

  @override
  String get sourceRemote => 'Comando origen';

  @override
  String get searchButtons => 'Pesquisar botões';

  @override
  String get searchButtonsHint => 'Enc., Volume, Silencio..';

  @override
  String get selectVisible => 'Selecionar visibles';

  @override
  String get clearVisible => 'Limpiar visibles';

  @override
  String protocolNamed(Object name) {
    return 'Protocolo: $name';
  }

  @override
  String get rawSignal => 'Bruto';

  @override
  String get legacyCode => 'Código antiguo';

  @override
  String importCount(int count) {
    return 'Importar $count';
  }

  @override
  String get storagePermissionDeniedLegacy =>
      'Permissão de almacenamiento negada (necesario en algums Android antiguos).';

  @override
  String get backupExportedToDownloads => 'Cópia exporteda a Descargas.';

  @override
  String failedToExport(Object error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String importedLegacyJsonBackup(int count) {
    return 'Foram importados $count comandos de uma cópia JSON antigua. Las macros não cambiaron.';
  }

  @override
  String get importFailedRemotesMustBeList =>
      'Importação falhada: \"remotes\" deve ser uma lista JSON se existe.';

  @override
  String get importFailedMacrosMustBeList =>
      'Importação falhada: \"macros\" deve ser uma lista JSON se existe.';

  @override
  String get importFailedInvalidBackupFormat =>
      'Importação falhada: formato de cópia não válido (se esperaba uma List antigua o un Map con remotes/macros).';

  @override
  String importedBackupRemotesOnly(int remoteCount) {
    return 'Foram importados $remoteCount comandos de a cópia. Las macros não cambiaron.';
  }

  @override
  String importedBackupRemotesAndMacros(int remoteCount, int macroCount) {
    return 'Foram importados $remoteCount comandos e $macroCount macros de a cópia.';
  }

  @override
  String get importFailedNoValidButtonsInIr =>
      'Importação falhada: não se encontraron botões válidos en o ficheiro.ir.';

  @override
  String get importedOneRemoteFromFlipper =>
      'Se importó 1 comando desde Flipper.ir. Las macros não cambiaron.';

  @override
  String get importFailedInvalidIrplus =>
      'Importação falhada: ficheiro irplus não válido (não se encontraron botões válidos).';

  @override
  String get importedOneRemoteFromIrplus =>
      'Se importó 1 comando desde irplus. Las macros não cambiaron.';

  @override
  String get importFailedInvalidLirc =>
      'Importação falhada: ficheiro LIRC não válido (não se encontraron códigos válidos/brutos).';

  @override
  String get importedOneRemoteFromLirc =>
      'Se importó 1 comando desde uma config LIRC. Las macros não cambiaron.';

  @override
  String get unsupportedFileTypeSelected =>
      'Se seleccionó un tipo de ficheiro não compatível.';

  @override
  String get importFailedInvalidUnreadableFile =>
      'Importação falhada: ficheiro não válido o ilegible.';

  @override
  String get bulkImportNoSupportedFilesInFolder =>
      'Importação masiva concluída: não se encontraron ficheiros compatíveis en a pasta.';

  @override
  String bulkImportNoRemotesImported(int skippedCount) {
    return 'Importação masiva concluída: não foram importados comandos. Se omitieron $skippedCount ficheiro(s).';
  }

  @override
  String bulkImportComplete(
    int importedCount,
    int supportedCount,
    int skippedCount,
  ) {
    return 'Importação masiva concluída: foram importados $importedCount comando(s) de $supportedCount ficheiro(s) compatível(s). Se omitieron $skippedCount ficheiro(s).';
  }

  @override
  String get storagePermissionDenied => 'Permissão de almacenamiento negada.';

  @override
  String get bulkImportFailedReadFolder =>
      'Importação masiva falhada: não se pudo leer o contenido de a pasta.';

  @override
  String bulkImportNoSupportedFilesSource(Object sourceLabel) {
    return 'Importação masiva concluída: não se encontraron ficheiros compatíveis ($sourceLabel).';
  }

  @override
  String get clearAction => 'Limpiar';

  @override
  String get saveAction => 'Guardar';

  @override
  String buttonsTitleCount(int count) {
    return 'Botões ($count)';
  }

  @override
  String get invalidStepEncountered => 'Se encontró un passo não válido';

  @override
  String failedToSendNamed(Object name) {
    return 'Falha ao enviar: $name';
  }

  @override
  String get buttonNotFound => 'Botão não encontrado';

  @override
  String buttonNotFoundNamed(Object name) {
    return 'Botão não encontrado: $name';
  }

  @override
  String get unknownButton => 'Botão desconhecido';

  @override
  String durationSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String durationMinutesSecondsShort(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationHoursMinutesShort(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get orientationFlippedTooltip =>
      'Orientación: invertida (toca para normal)';

  @override
  String get orientationNormalTooltip =>
      'Orientación: normal (toca para inverter)';

  @override
  String get noSteps => 'Sem passos';

  @override
  String stepProgress(int current, int total) {
    return 'Passo $current / $total';
  }

  @override
  String get completed => 'Completado';

  @override
  String get paused => 'En pausa';

  @override
  String get running => 'En curso';

  @override
  String get ready => 'Listo';

  @override
  String stepsProgress(int current, int total) {
    return '$current / $total passos';
  }

  @override
  String get waiting => 'A aguardar';

  @override
  String secondsRemaining(Object seconds) {
    return 'Quedan ${seconds}s';
  }

  @override
  String millisecondsShort(int ms) {
    return '${ms}ms';
  }

  @override
  String get tapContinueWhenReady =>
      'Toca Continuar quando estés listo para o seguinte passo';

  @override
  String get error => 'Error';

  @override
  String get macroCompleted => 'Macro Completado';

  @override
  String finishedIn(Object duration) {
    return 'Terminado en $duration';
  }

  @override
  String get sequence => 'Secuencia';

  @override
  String waitMilliseconds(int ms) {
    return 'Aguardar ${ms}ms';
  }

  @override
  String get runAgain => 'Executar de novo';

  @override
  String get startMacro => 'Iniciar Macro';

  @override
  String get continueAction => 'Continuar';

  @override
  String get unnamedRemote => 'Unnamed Comando';

  @override
  String get enterMacroName => 'Introduza un nome para a macro';

  @override
  String get addAtLeastOneStep => 'Adicione ao menos un passo';

  @override
  String get fixInvalidSteps => 'Corrige os passos não válidos';

  @override
  String get unknownCommand => 'Desconhecido Command';

  @override
  String get unnamedCommand => 'Comando sem nome';

  @override
  String get iconCommand => 'Comando de icono';

  @override
  String get selectDelay => 'Selecionar Delay';

  @override
  String keepMilliseconds(int ms) {
    return 'Manter: ${ms}ms';
  }

  @override
  String get custom => 'Personalizado';

  @override
  String get enterCustomDelayDuration =>
      'Introduza uma duración personalizada de pausa';

  @override
  String millisecondsLong(int ms) {
    return '$ms milisegundos';
  }

  @override
  String secondsLong(Object seconds, Object plural) {
    return '$seconds segundo$plural';
  }

  @override
  String get customDelay => 'Pausa personalizada';

  @override
  String get delayMillisecondsLabel => 'Pausa (milisegundos)';

  @override
  String get delayMillisecondsHint => 'p. ej., 3000';

  @override
  String get recommendedDelayRange =>
      'Recommended: 250-5000ms for most dispositivos';

  @override
  String get enterValidPositiveNumber => 'Introduza un número positivo válido';

  @override
  String get ok => 'OK';

  @override
  String get remote => 'Comando';

  @override
  String get macroName => 'Nome de a macro';

  @override
  String get macroNameHint => 'e.g., i-cybie Advanced Modo';

  @override
  String stepsTitleCount(int count) {
    return 'Passos ($count)';
  }

  @override
  String get noStepsYet => 'Ainda não há passos';

  @override
  String get addCommandsAndDelaysHint =>
      'Adicione baixo comandos e pausas para criar o seu secuencia';

  @override
  String get addStep => 'Adicionar passo';

  @override
  String get reorderStepsHint =>
      'Dica: arraste o asa para reordenar passos. Toca un passo para editarlo.';

  @override
  String reorderStep(int index) {
    return 'Reordenar passo $index';
  }

  @override
  String get pressAndDragToChangeStepOrder =>
      'Mantenha premido e arraste para cambiar o orden de os passos';

  @override
  String deleteStep(int index) {
    return 'Eliminar passo $index';
  }

  @override
  String get invalidStepTapToFix => 'Passo não válido - toca para corregir';

  @override
  String get sendIrCommand => 'Enviar comando IR';

  @override
  String get waitForUserConfirmation => 'Aguardar confirmación do usuario';

  @override
  String get notImplemented => 'Não implementado';

  @override
  String frequencyKhz(int value) {
    return '$value kHz';
  }

  @override
  String get necProtocolShort => 'NEC';

  @override
  String get msbShort => 'MSB';

  @override
  String get layoutWide => 'Ancho';

  @override
  String get iconButton => 'Icon botão';

  @override
  String get imageButton => 'Image botão';

  @override
  String get noSignalInfo => 'Sem info de sinal';

  @override
  String get proceed => 'Continuar';

  @override
  String get discard => 'Descartar';

  @override
  String get continueEditing => 'Continue editing';

  @override
  String get unsavedChangesTitle => 'Unsaved changes';

  @override
  String get unsavedMacroChangesMessage =>
      'Discard your macro changes and leave this screen?';

  @override
  String get stopMacroBeforeLeaving =>
      'Stop the macro before leaving this screen.';

  @override
  String get stopTestingBeforeLeaving =>
      'Stop testing before leaving this screen.';

  @override
  String get idle => 'Inactivo';

  @override
  String get start => 'Iniciar';

  @override
  String get resume => 'Retomar';

  @override
  String get pause => 'Pausa';

  @override
  String get stopped => 'Detenido';

  @override
  String get copy => 'Copiar';

  @override
  String get send => 'Enviar';

  @override
  String get step => 'Passo';

  @override
  String get addToRemote => 'Adicionar ao comando';

  @override
  String get noDescriptionAvailable => 'Não há descripción disponible.';

  @override
  String get notAvailableSymbol => '-';

  @override
  String get irFinderKaseikyoVendorInvalid =>
      'El proveedor Kaseikyo deve tener exactamente 4 dígitos hex.';

  @override
  String get irFinderDatabaseNotReady =>
      'La base de dados ainda não está lista.';

  @override
  String get irFinderSelectBrandFirst =>
      'Selecione primeiroo uma marca en Configuração.';

  @override
  String get irFinderBruteforceUnavailable =>
      'La força bruta ainda não está disponible para este protocolo.';

  @override
  String get irFinderInvalidPrefix => 'Prefijo não válido.';

  @override
  String irFinderBrandValue(Object value) {
    return 'Marca: $value';
  }

  @override
  String irFinderModelValue(Object value) {
    return 'Modelo: $value';
  }

  @override
  String irFinderKeyValue(Object value) {
    return 'Tecla: $value';
  }

  @override
  String irFinderRemoteNumber(Object value) {
    return 'Comando n.º $value';
  }

  @override
  String get irFinderJumpOffsetHelper =>
      'Introduza un índice base 0 dentro de os resultados filtrados e ordenados.';

  @override
  String get irFinderJumpCursorHelper =>
      'Introduza un cursor hex base 0 dentro do espaço de força bruta.';

  @override
  String get irFinderSetupTab => 'Configuração';

  @override
  String get irFinderTestTab => 'Probar';

  @override
  String get irFinderResultsTab => 'Resultados';

  @override
  String get irFinderContinueToTest => 'Continuar a Teste';

  @override
  String get irFinderKaseikyoVendorTitle => 'Proveedor Kaseikyo';

  @override
  String get irFinderCustomVendorLabel => 'Proveedor personalizado (4 hex)';

  @override
  String get irFinderBrowseDbCandidates => 'Explorar candidatos de BD…';

  @override
  String get irFinderEditSetup => 'Editar configuração';

  @override
  String get irFinderNoSavedHits =>
      'Ainda não há aciertos guardados. En a página Teste, pulsa \"Guardar acierto\" quando o dispositivo responda.';

  @override
  String get irFinderBackToTest => 'Voltar a Teste';

  @override
  String get irFinderLargeSearchSpaceTitle => 'Espaço de pesquisa grande';

  @override
  String irFinderLargeSearchSpaceBody(Object human) {
    return 'Este espaço de força bruta es muy grande ($human posibilidades). IR Finder respetará os seus intentos máximos e a espera, mas evita saturar dispositivos IR.\n\nRecomendación: usa primeiroo o modo Base de dados y/o introduza bytes de prefijo conocidos para reducir o espaço.';
  }

  @override
  String get irFinderDatabaseSession => 'Sesión de base de dados';

  @override
  String get irFinderBruteforceSession => 'Sesión de força bruta';

  @override
  String get irFinderResumeLastSession => 'Retomar última sesión';

  @override
  String irFinderResumeBrandModel(Object brand, Object model) {
    return 'Marca: $brand · Modelo: $model';
  }

  @override
  String irFinderResumePrefix(Object value) {
    return 'Prefijo: $value';
  }

  @override
  String irFinderResumeProgress(Object progress, Object when) {
    return 'Progreso: $progress · Início: $when';
  }

  @override
  String get irFinderApplyResume => 'Aplicar e retomar';

  @override
  String get irFinderBruteforceMode => 'Força bruta';

  @override
  String get irFinderDatabaseAssistedMode => 'Asistido por BD';

  @override
  String irFinderProtocolTitle(Object name) {
    return 'Protocolo: $name';
  }

  @override
  String get irFinderProtocolLabel => 'Protocolo IR';

  @override
  String get irFinderProtocolHelper =>
      'Controla a codificación e por tanto o espaço de pesquisa.';

  @override
  String get irFinderKnownPrefixLabel =>
      'Prefijo conocido (bytes hex, opcional)';

  @override
  String get irFinderKnownPrefixHint => 'A1B2, A1 B2, A1:B2, 0xA1 0xB2';

  @override
  String irFinderKnownPrefixHelperPayload(int digits) {
    return 'Carga: $digits dígito(s) hex';
  }

  @override
  String irFinderKnownPrefixHelperPayloadExample(int digits, Object example) {
    return 'Carga: $digits dígito(s) hex · Ejemplo: $example';
  }

  @override
  String irFinderKnownPrefixHelperPayloadMax(int digits, int bytes) {
    return 'Carga: $digits dígito(s) hex · Prefijo máx.: $bytes byte(s)';
  }

  @override
  String irFinderKnownPrefixHelperPayloadExampleMax(
    int digits,
    Object example,
    int bytes,
  ) {
    return 'Carga: $digits dígito(s) hex · Ejemplo: $example · Prefijo máx.: $bytes byte(s)';
  }

  @override
  String irFinderKnownPrefixHelperExample(Object example) {
    return 'Ejemplo: $example';
  }

  @override
  String get irFinderKnownPrefixHelperFallback =>
      'Introduza os primeiroos bytes conocidos para reducir o espaço de pesquisa.';

  @override
  String get irFinderDatabaseMode => 'Base de dados';

  @override
  String irFinderNormalizedPrefixValue(Object value) {
    return 'Prefijo normalizado: $value';
  }

  @override
  String get irFinderNormalizedPrefix => 'Prefijo normalizado';

  @override
  String get irFinderBruteforceNotConfigured =>
      'La força bruta ainda não está configurada para este protocolo.';

  @override
  String irFinderAllLimit(Object value) {
    return 'Tudo ($value)';
  }

  @override
  String get irFinderTestControls => 'Controlos de teste';

  @override
  String irFinderPayloadLength(int digits) {
    return 'Longitud de carga: $digits dígito(s) hex.';
  }

  @override
  String irFinderSearchSpace(Object value) {
    return 'Espaço de pesquisa: $value posibilidades (tras as restricciones do prefijo).';
  }

  @override
  String get irFinderCooldownMs => 'Espera (ms)';

  @override
  String get irFinderMaxAttemptsPerRun => 'Intentos máx. (por execução)';

  @override
  String get irFinderTestAllCombinations => 'Probar todas as combinaciones';

  @override
  String irFinderTestAllCombinationsHint(Object value) {
    return 'Se ejecuta hasta agotar o espaço de pesquisa. Límite efectivo: $value';
  }

  @override
  String get irFinderAttempts => 'Intentos';

  @override
  String irFinderAttemptsSliderRange(int max) {
    return 'Rango do deslizador: 1–$max (escreva cualquier número para valores mayores)';
  }

  @override
  String irFinderMaxButton(int value) {
    return 'Máx.\n$value';
  }

  @override
  String irFinderEffectiveLimitThisRun(Object value) {
    return 'Límite efectivo en esta execução: $value';
  }

  @override
  String get irFinderBruteforceTip =>
      'Dica: usa primeiroo o modo Base de dados; a força bruta va melhor con un prefijo conocido (por ejemplo, os primeiroos 1–4 bytes).';

  @override
  String get irFinderDatabaseInitFailed =>
      'Falhou a inicialização de a base de dados.';

  @override
  String get irFinderPreparingDatabase =>
      'Preparando base local de códigos IR…';

  @override
  String get irFinderDatabaseAssistedSearch => 'Pesquisa asistida por BD';

  @override
  String get irFinderBrand => 'Marca';

  @override
  String get irFinderSelectBrand => 'Selecionar marca';

  @override
  String get irFinderModelOptional => 'Modelo (opcional)';

  @override
  String get irFinderSelectBrandFirstShort => 'Selecione primeiroo uma marca';

  @override
  String get irFinderSelectModelRecommended =>
      'Selecione un modelo (recomendado)';

  @override
  String get irFinderOnlySelectedProtocol => 'Apenas protocolo selecionado';

  @override
  String get irFinderOnlySelectedProtocolHint =>
      'Filtra as teclas ao protocolo escolhido. Desactívalo para ver todos os protocolos.';

  @override
  String get irFinderQuickWinsFirst => 'Aciertos rápidos primeiroo';

  @override
  String get irFinderQuickWinsFirstHint =>
      'Prioriza teclas tipo POWER, MUTE, VOL e CH antes que otras mais profundas.';

  @override
  String get irFinderMaxKeysPerRun => 'Teclas máx. a probar (por execução)';

  @override
  String get irFinderTesting => 'Probando…';

  @override
  String get irFinderCooldown => 'Espera';

  @override
  String get irFinderEta => 'ETA';

  @override
  String get irFinderMode => 'Modo';

  @override
  String get irFinderRetryLast => 'Tentar novamente a última';

  @override
  String get irFinderTrigger => 'Disparar';

  @override
  String get irFinderJump => 'Saltar…';

  @override
  String get irFinderSaveHit => 'Guardar acierto';

  @override
  String irFinderEtaSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String irFinderEtaMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String irFinderEtaHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String irFinderLastAttemptedCode(Object value) {
    return 'Último código probado: $value';
  }

  @override
  String get irFinderStartTestingToSeeLastCode =>
      'Empieza a teste para ver o último código intentado.';

  @override
  String irFinderFromDb(Object value) {
    return 'De BD: $value';
  }

  @override
  String get irFinderFromBruteforce =>
      'De força bruta (generado por o codificador de protocolo).';

  @override
  String irFinderSendError(Object error) {
    return 'Erro de envio: $error';
  }

  @override
  String irFinderSourceValue(Object value) {
    return 'Origen: $value';
  }

  @override
  String get irFinderResultsNote =>
      'Los resultados permiten Probar e Copiar ao instante. La integración directa para adicionar ao comando pode ampliarse luego en o editor.';

  @override
  String get irFinderBrowseDbCandidatesTitle => 'Explorar candidatos de BD';

  @override
  String get irFinderFilterByLabelOrHex => 'Filtrar por etiqueta o hex…';

  @override
  String get irFinderJumpHere => 'Saltar aqui';

  @override
  String get irFinderSelectModel => 'Selecionar modelo';

  @override
  String get irFinderSearchBrands => 'Pesquisar marcas…';

  @override
  String get irFinderSearchModels => 'Pesquisar modelos…';

  @override
  String get iconPickerTitle => 'Selecionar icono';

  @override
  String get iconPickerSearchHint => 'Pesquisar iconos..';

  @override
  String get iconPickerNoIconsFound => 'Não se encontraron iconos';

  @override
  String iconPickerIconsAvailable(int count) {
    return '$count iconos disponibles';
  }

  @override
  String get iconPickerCategoryAll => 'Tudo';

  @override
  String get iconPickerCategoryMedia => 'Medios';

  @override
  String get iconPickerCategoryVolume => 'Volume';

  @override
  String get iconPickerCategoryNavigation => 'Navegación';

  @override
  String get iconPickerCategoryPower => 'Enc.';

  @override
  String get iconPickerCategoryNumbers => 'Números';

  @override
  String get iconPickerCategorySettings => 'Definições';

  @override
  String get iconPickerCategoryDisplay => 'Ecrã';

  @override
  String get iconPickerCategoryInput => 'Entrada';

  @override
  String get iconPickerCategoryFavorite => 'Favorito';

  @override
  String get universalPowerTitle => 'Ligado universal';

  @override
  String get universalPowerRunTab => 'Executar';

  @override
  String get universalPowerUseResponsibly => 'Úsalo con responsabilidad';

  @override
  String get universalPowerConsentBody =>
      'Ligado universal cicla códigos IR de ligado. Úsalo apenas en dispositivos que posees o controlas. Deténlo en cuanto o dispositivo responda.';

  @override
  String get universalPowerConsentCheckbox => 'Poseo o controlo o dispositivo';

  @override
  String get universalPowerSetupBody =>
      'Cicla códigos de ligado para a marca escolhida. Deténlo en cuanto o dispositivo responda.';

  @override
  String universalPowerLastSent(Object value) {
    return 'Último enviado: $value';
  }

  @override
  String get universalPowerNoCodesFound =>
      'Não se encontraron códigos de ligado. Intenta ampliar a pesquisa.';

  @override
  String get universalPowerUnableToStart => 'Não se pudo iniciar.';

  @override
  String get universalPowerAllBrands => 'Todas as marcas (sem filtro)';

  @override
  String get universalPowerClearBrandFilter => 'Limpiar filtro de marca';

  @override
  String get universalPowerBroadenSearch => 'Amplía a pesquisa se hace falta';

  @override
  String get universalPowerBroadenSearchHint =>
      'Se não se encuentran etiquetas de ligado, incluye otras teclas.';

  @override
  String get universalPowerAdditionalPatternsDepth =>
      'Profundidad de patrones extra';

  @override
  String get universalPowerDepth1 => 'Apenas prioridad: POWER/OFF';

  @override
  String get universalPowerDepth2 => 'Incluir alias de POWER';

  @override
  String get universalPowerDepth3 => 'Incluir etiquetas secundarias de ligado';

  @override
  String get universalPowerDepth4 =>
      'Incluir todas as etiquetas (menor prioridad)';

  @override
  String get universalPowerLoopUntilStopped => 'Repetir hasta parar';

  @override
  String get universalPowerLoopUntilStoppedHint =>
      'Segue ciclando a cola hasta que a detengas.';

  @override
  String get universalPowerDelayBetweenCodes => 'Pausa entre códigos';

  @override
  String get universalPowerStart => 'Iniciar Ligado universal';

  @override
  String get universalPowerRunStatus => 'Estado de execução';

  @override
  String universalPowerProgress(Object value) {
    return 'Progreso: $value';
  }

  @override
  String get universalPowerPausedInBackground =>
      'En pausa porque a app pasó a segundo plano.';

  @override
  String get universalPowerSendOneCode => 'Enviar un código';

  @override
  String get universalPowerStopWhenDeviceResponds =>
      'Deténlo en cuanto o dispositivo responda.';

  @override
  String get iconNamePlay => 'Reproduzir';

  @override
  String get iconNamePause => 'Pausa';

  @override
  String get iconNameStop => 'Parar';

  @override
  String get iconNameFastForward => 'Avance rápido';

  @override
  String get iconNameRewind => 'Rebobinar';

  @override
  String get iconNameSkipNext => 'Seguinte';

  @override
  String get iconNameSkipPrevious => 'Anterior';

  @override
  String get iconNameReplay => 'Repetir';

  @override
  String get iconNameForward10S => 'Adelante 10s';

  @override
  String get iconNameForward30S => 'Adelante 30s';

  @override
  String get iconNameReplay10S => 'Repetir 10s';

  @override
  String get iconNameReplay30S => 'Repetir 30s';

  @override
  String get iconNameRecord => 'Grabar';

  @override
  String get iconNameRecordAlt => 'Grabar Alt';

  @override
  String get iconNameEject => 'Expulsar';

  @override
  String get iconNameShuffle => 'Aleatorio';

  @override
  String get iconNameRepeat => 'Repetir';

  @override
  String get iconNameRepeatOne => 'Repetir uma';

  @override
  String get iconNameVolumeUp => 'Volume Cima';

  @override
  String get iconNameVolumeDown => 'Volume Baixo';

  @override
  String get iconNameVolumeOff => 'Volume Desligado';

  @override
  String get iconNameMute => 'Sil.';

  @override
  String get iconNameSpeaker => 'Altavoz';

  @override
  String get iconNameSurroundSound => 'Envolvente Sonido';

  @override
  String get iconNameEqualizer => 'Ecualizador';

  @override
  String get iconNameAudio => 'Áudio';

  @override
  String get iconNameMicrophone => 'Micrófono';

  @override
  String get iconNameMicOff => 'Mic Desligado';

  @override
  String get iconNameUp => 'Cima';

  @override
  String get iconNameDown => 'Baixo';

  @override
  String get iconNameLeft => 'Esquerda';

  @override
  String get iconNameRight => 'Direita';

  @override
  String get iconNameArrowUp => 'Seta Cima';

  @override
  String get iconNameArrowDown => 'Seta Baixo';

  @override
  String get iconNameArrowLeft => 'Seta Esquerda';

  @override
  String get iconNameArrowRight => 'Seta Direita';

  @override
  String get iconNameNavigation => 'Navegación';

  @override
  String get iconNameChevronLeft => 'Chevron Esquerda';

  @override
  String get iconNameChevronRight => 'Chevron Direita';

  @override
  String get iconNameExpandLess => 'Expandir Menos';

  @override
  String get iconNameExpandMore => 'Expandir Mais';

  @override
  String get iconNameCollapse => 'Contraer';

  @override
  String get iconNameExpand => 'Expandir';

  @override
  String get iconNameCircleUp => 'Círculo Cima';

  @override
  String get iconNameCircleDown => 'Círculo Baixo';

  @override
  String get iconNameCircleLeft => 'Círculo Esquerda';

  @override
  String get iconNameCircleRight => 'Círculo Direita';

  @override
  String get iconNameOkSelect => 'OK/Selecionar';

  @override
  String get iconNameConfirm => 'Confirmar';

  @override
  String get iconNameCancel => 'Cancelar';

  @override
  String get iconNameClose => 'Fechar';

  @override
  String get iconNameHome => 'Início';

  @override
  String get iconNameReturn => 'Voltar';

  @override
  String get iconNameExit => 'Salir';

  @override
  String get iconNameUndo => 'Anular';

  @override
  String get iconNameRedo => 'Rehacer';

  @override
  String get iconNamePower => 'Enc.';

  @override
  String get iconNamePowerAlt => 'Ligado Alt';

  @override
  String get iconNamePowerOff => 'Power Desligado';

  @override
  String get iconNameOn => 'Ligado';

  @override
  String get iconNameOff => 'Desligado';

  @override
  String get iconNameToggleOn => 'Alternar ligado';

  @override
  String get iconNameToggleOff => 'Alternar desligado';

  @override
  String get iconNameRestart => 'Reiniciar';

  @override
  String get iconNameNum1 => '1';

  @override
  String get iconNameNum2 => '2';

  @override
  String get iconNameNum3 => '3';

  @override
  String get iconNameNum4 => '4';

  @override
  String get iconNameNum5 => '5';

  @override
  String get iconNameNum6 => '6';

  @override
  String get iconNameNum7 => '7';

  @override
  String get iconNameNum8 => '8';

  @override
  String get iconNameNum9 => '9';

  @override
  String get iconNameNum92 => '9+';

  @override
  String get iconNameNum0 => '0';

  @override
  String get iconNameOne => 'Una';

  @override
  String get iconNameTwo => 'Dos';

  @override
  String get iconNameThree => 'Tres';

  @override
  String get iconNameFour => 'Cuatro';

  @override
  String get iconNameFive => 'Cinco';

  @override
  String get iconNameSix => 'Seis';

  @override
  String get iconNamePlus => 'Mais';

  @override
  String get iconNameMinus => 'Menos';

  @override
  String get iconNameAddCircle => 'Adicionar círculo';

  @override
  String get iconNameRemoveCircle => 'Remove Círculo';

  @override
  String get iconNameSettings => 'Definições';

  @override
  String get iconNameMenu => 'Menú';

  @override
  String get iconNameMoreVertical => 'Mais Vertical';

  @override
  String get iconNameMoreHorizontal => 'Mais Horizontal';

  @override
  String get iconNameTune => 'Ajuste';

  @override
  String get iconNameRemoteSettings => 'Comando Definições';

  @override
  String get iconNameInfo => 'Informação';

  @override
  String get iconNameInfoOutline => 'Informação contorno';

  @override
  String get iconNameHelp => 'Ajuda';

  @override
  String get iconNameHelpOutline => 'Ajuda Contorno';

  @override
  String get iconNameList => 'Lista';

  @override
  String get iconNameViewList => 'Vista List';

  @override
  String get iconNameViewGrid => 'Vista Grelha';

  @override
  String get iconNameApps => 'Apps';

  @override
  String get iconNameWidgets => 'Widgets';

  @override
  String get iconNameTv => 'TV';

  @override
  String get iconNameMonitor => 'Monitor';

  @override
  String get iconNameDesktop => 'Escritorio';

  @override
  String get iconNameBrightnessHigh => 'Brilho alto';

  @override
  String get iconNameBrightnessMedium => 'Brilho medio';

  @override
  String get iconNameBrightnessLow => 'Brilho bajo';

  @override
  String get iconNameAutoBrightness => 'Brilho automático';

  @override
  String get iconNameLightMode => 'Luz Modo';

  @override
  String get iconNameDarkMode => 'Dark Modo';

  @override
  String get iconNameContrast => 'Contraste';

  @override
  String get iconNameHdrOn => 'HDR ligado';

  @override
  String get iconNameHdrOff => 'HDR Desligado';

  @override
  String get iconNameAspectRatio => 'Relación de aspecto';

  @override
  String get iconNameCrop => 'Recortar';

  @override
  String get iconNameZoomIn => 'Acercar';

  @override
  String get iconNameZoomOut => 'Alejar';

  @override
  String get iconNameFullscreen => 'Ecrã completa';

  @override
  String get iconNameExitFullscreen => 'Exit Ecrã completa';

  @override
  String get iconNameFitScreen => 'Ajustar ecrã';

  @override
  String get iconNamePip => 'PiP';

  @override
  String get iconNameCropFree => 'Recortar Free';

  @override
  String get iconNameInput => 'Entrada';

  @override
  String get iconNameCable => 'Cable';

  @override
  String get iconNameCast => 'Transmitir';

  @override
  String get iconNameCastConnected => 'Transmitir Connected';

  @override
  String get iconNameScreenShare => 'Screen Compartir';

  @override
  String get iconNameBluetooth => 'Bluetooth';

  @override
  String get iconNameWifi => 'WiFi';

  @override
  String get iconNameRouter => 'Router';

  @override
  String get iconNameMemory => 'Memoria';

  @override
  String get iconNameGameConsole => 'Consola de juegos';

  @override
  String get iconNameGaming => 'Juegos';

  @override
  String get iconNameMedia => 'Medios';

  @override
  String get iconNameMusicQueue => 'Música Cola';

  @override
  String get iconNameVideoLibrary => 'Biblioteca de video';

  @override
  String get iconNamePhotoLibrary => 'Foto Library';

  @override
  String get iconNameComponent => 'Componente';

  @override
  String get iconNameHdmi => 'HDMI';

  @override
  String get iconNameComposite => 'Compuisto';

  @override
  String get iconNameAntenna => 'Antena';

  @override
  String get iconNameFavorite => 'Favorito';

  @override
  String get iconNameFavoriteOutline => 'Favorito Contorno';

  @override
  String get iconNameStar => 'Estrella';

  @override
  String get iconNameStarOutline => 'Estrella contorno';

  @override
  String get iconNameBookmark => 'Marcador';

  @override
  String get iconNameBookmarkOutline => 'Marcador contorno';

  @override
  String get iconNameFlag => 'Bandera';

  @override
  String get iconNameCheck => 'Marca';

  @override
  String get iconNameDone => 'Listo';

  @override
  String get iconNameDoneAll => 'Concluído Tudo';

  @override
  String get iconNameSchedule => 'Programación';

  @override
  String get iconNameTimer => 'Temporizador';

  @override
  String get iconNameTime => 'Tiempo';

  @override
  String get iconNameAlarm => 'Alarma';

  @override
  String get iconNameNotifications => 'Notificaciones';

  @override
  String get iconNameLock => 'Bloqueo';

  @override
  String get iconNameUnlock => 'Desbloquear';

  @override
  String get iconNameLight => 'Claro';

  @override
  String get iconNameLightOutline => 'Luz Contorno';

  @override
  String get iconNameWarmLight => 'Cálida Luz';

  @override
  String get iconNameSunny => 'Soleado';

  @override
  String get iconNameCloudy => 'Nublado';

  @override
  String get iconNameNight => 'Noche';

  @override
  String get iconNameFlare => 'Destello';

  @override
  String get iconNameGradient => 'Degradado';

  @override
  String get iconNameInvertColors => 'Inverter Colores';

  @override
  String get iconNamePalette => 'Paleta';

  @override
  String get iconNameColor => 'Cor';

  @override
  String get iconNameTonality => 'Tonalidad';

  @override
  String get iconNameSearch => 'Pesquisar';

  @override
  String get iconNameRefresh => 'Atualizar';

  @override
  String get iconNameSync => 'Sincronizar';

  @override
  String get iconNameUpdate => 'Atualizar';

  @override
  String get iconNameDownload => 'Descargar';

  @override
  String get iconNameUpload => 'Subir';

  @override
  String get iconNameCloud => 'Nube';

  @override
  String get iconNameFolder => 'Pasta';

  @override
  String get iconNameDelete => 'Eliminar';

  @override
  String get iconNameEdit => 'Editar';

  @override
  String get iconNameSave => 'Guardar';

  @override
  String get iconNameShare => 'Compartir';

  @override
  String get iconNamePrint => 'Imprimir';

  @override
  String get iconNameLanguage => 'Idioma';

  @override
  String get iconNameTranslate => 'Traducir';

  @override
  String get iconNameMicNone => 'Mic Ningum';

  @override
  String get iconNameSubtitles => 'Legendas';

  @override
  String get iconNameClosedCaption => 'Legendas cerrados';

  @override
  String get iconNameMusic => 'Música';

  @override
  String get iconNameMovie => 'Película';

  @override
  String get iconNameTheater => 'Teatro';

  @override
  String get iconNameLiveTv => 'En vivo TV';

  @override
  String get iconNameRadio => 'Radio';

  @override
  String get iconNameCamera => 'Câmara';

  @override
  String get iconNameVideoCamera => 'Video Câmara';

  @override
  String get iconNamePhotoCamera => 'Foto Câmara';

  @override
  String get iconNameSlowMotion => 'Lento Movimiento';

  @override
  String get iconNameSpeed => 'Velocidad';

  @override
  String get iconNameVideoSettings => 'Video Definições';

  @override
  String get iconNameAudioTrack => 'Pista de áudio';

  @override
  String get iconNameGraphicEq => 'Gráfico EQ';

  @override
  String get iconNameMusicVideo => 'Música Video';

  @override
  String get iconNamePlaylist => 'Lista';

  @override
  String get iconNameQueue => 'Cola';

  @override
  String get iconNameNum0Fa => '0 FA';

  @override
  String get iconNameNum1Fa => '1 FA';

  @override
  String get iconNameNum2Fa => '2 FA';

  @override
  String get iconNameNum3Fa => '3 FA';

  @override
  String get iconNameNum4Fa => '4 FA';

  @override
  String get iconNameNum5Fa => '5 FA';

  @override
  String get iconNameNum6Fa => '6 FA';

  @override
  String get iconNameNum7Fa => '7 FA';

  @override
  String get iconNameNum8Fa => '8 FA';

  @override
  String get iconNameNum9Fa => '9 FA';

  @override
  String get iconNameHashFa => 'Hash # FA';

  @override
  String get iconNamePercentFa => 'Porcentaje % FA';

  @override
  String get iconNameDivideFa => 'Dividir ÷ FA';

  @override
  String get iconNameMultiplyFa => 'Multiplicar × FA';

  @override
  String get iconNameEqualsFa => 'Igual = FA';

  @override
  String get iconNameNotEqualFa => 'Distinto ≠ FA';

  @override
  String get iconNameGreaterThanFa => 'Mayor que > FA';

  @override
  String get iconNameLessThanFa => 'Menos Than < FA';

  @override
  String get iconNameAsteriskFa => 'Asterisco * FA';

  @override
  String get iconNameAFa => 'A FA';

  @override
  String get iconNameBFa => 'B FA';

  @override
  String get iconNameCFa => 'C FA';

  @override
  String get iconNameDFa => 'D FA';

  @override
  String get iconNameEFa => 'E FA';

  @override
  String get iconNameFFa => 'F FA';

  @override
  String get iconNameGFa => 'G FA';

  @override
  String get iconNameHFa => 'H FA';

  @override
  String get iconNameIFa => 'I FA';

  @override
  String get iconNameJFa => 'J FA';

  @override
  String get iconNameKFa => 'K FA';

  @override
  String get iconNameLFa => 'L FA';

  @override
  String get iconNameMFa => 'M FA';

  @override
  String get iconNameNFa => 'N FA';

  @override
  String get iconNameOFa => 'O FA';

  @override
  String get iconNamePFa => 'P FA';

  @override
  String get iconNameQFa => 'Q FA';

  @override
  String get iconNameRFa => 'R FA';

  @override
  String get iconNameSFa => 'S FA';

  @override
  String get iconNameTFa => 'T FA';

  @override
  String get iconNameUFa => 'U FA';

  @override
  String get iconNameVFa => 'V FA';

  @override
  String get iconNameWFa => 'W FA';

  @override
  String get iconNameXFa => 'X FA';

  @override
  String get iconNameYFa => 'Y FA';

  @override
  String get iconNameZFa => 'Z FA';

  @override
  String get iconNamePlayFa => 'Reproduzir FA';

  @override
  String get iconNamePauseFa => 'Pausa FA';

  @override
  String get iconNameStopFa => 'Parar FA';

  @override
  String get iconNamePlayFaOutline => 'Reproduzir FA Contorno';

  @override
  String get iconNamePauseFaOutline => 'Pausa FA Contorno';

  @override
  String get iconNameStopFaOutline => 'Parar FA Contorno';

  @override
  String get iconNameBackwardFa => 'Atrás FA';

  @override
  String get iconNameForwardFa => 'Adelante FA';

  @override
  String get iconNamePreviousFa => 'Anterior FA';

  @override
  String get iconNameNextFa => 'Seguinte FA';

  @override
  String get iconNameRewindFa => 'Rebobinar FA';

  @override
  String get iconNameFastForwardFa => 'Avance rápido FA';

  @override
  String get iconNameRepeatFa => 'Repetir FA';

  @override
  String get iconNameShuffleFa => 'Aleatorio FA';

  @override
  String get iconNameEjectFa => 'Expulsar FA';

  @override
  String get iconNameFilmFa => 'Película FA';

  @override
  String get iconNameVideoFa => 'Video FA';

  @override
  String get iconNameMusicFa => 'Música FA';

  @override
  String get iconNameMicrophoneFa => 'Micrófono FA';

  @override
  String get iconNameCameraFa => 'Câmara FA';

  @override
  String get iconNameCameraRetroFa => 'Câmara Retro FA';

  @override
  String get iconNameVolumeHighFa => 'Volume alto FA';

  @override
  String get iconNameVolumeLowFa => 'Volume bajo FA';

  @override
  String get iconNameVolumeOffFa => 'Volume Desligado FA';

  @override
  String get iconNameMuteFa => 'Silencio FA';

  @override
  String get iconNameMicMuteFa => 'Mic silenciado FA';

  @override
  String get iconNameHeadphonesFa => 'Auriculares FA';

  @override
  String get iconNameSpeakerFa => 'Altavoz FA';

  @override
  String get iconNameUpFa => 'Cima FA';

  @override
  String get iconNameDownFa => 'Baixo FA';

  @override
  String get iconNameLeftFa => 'Esquerda FA';

  @override
  String get iconNameRightFa => 'Direita FA';

  @override
  String get iconNameUpFaOutline => 'Cima FA Contorno';

  @override
  String get iconNameDownFaOutline => 'Baixo FA Contorno';

  @override
  String get iconNameLeftFaOutline => 'Esquerda FA Contorno';

  @override
  String get iconNameRightFaOutline => 'Direita FA Contorno';

  @override
  String get iconNameArrowUpFa => 'Seta Cima FA';

  @override
  String get iconNameArrowDownFa => 'Seta Baixo FA';

  @override
  String get iconNameArrowLeftFa => 'Seta Esquerda FA';

  @override
  String get iconNameArrowRightFa => 'Seta Direita FA';

  @override
  String get iconNameChevronUpFa => 'Chevron Cima FA';

  @override
  String get iconNameChevronDownFa => 'Chevron Baixo FA';

  @override
  String get iconNameChevronLeftFa => 'Chevron Esquerda FA';

  @override
  String get iconNameChevronRightFa => 'Chevron Direita FA';

  @override
  String get iconNameOkFa => 'OK FA';

  @override
  String get iconNameOkFaOutline => 'OK FA Contorno';

  @override
  String get iconNameCheckFa => 'Marca FA';

  @override
  String get iconNameCloseFa => 'Fechar FA';

  @override
  String get iconNameCloseCircleFa => 'Close Círculo FA';

  @override
  String get iconNameHomeFa => 'Início FA';

  @override
  String get iconNameUndoFa => 'Anular FA';

  @override
  String get iconNameRedoFa => 'Rehacer FA';

  @override
  String get iconNameRotateFa => 'Girar FA';

  @override
  String get iconNameSearchFa => 'Pesquisar FA';

  @override
  String get iconNameRefreshFa => 'Atualizar FA';

  @override
  String get iconNamePowerOffFa => 'Power Desligado FA';

  @override
  String get iconNamePlugFa => 'Enchufe FA';

  @override
  String get iconNameToggleOnFa => 'Alternar ligado FA';

  @override
  String get iconNameToggleOffFa => 'Alternar desligado FA';

  @override
  String get iconNameSettingsFa => 'Definições FA';

  @override
  String get iconNameSettingsAltFa => 'Definições Alt FA';

  @override
  String get iconNameMenuFa => 'Menú FA';

  @override
  String get iconNameMoreFa => 'Mais FA';

  @override
  String get iconNameMoreVerticalFa => 'Mais Vertical FA';

  @override
  String get iconNameInfoFa => 'Informação FA';

  @override
  String get iconNameInfoFaOutline => 'Informação FA contorno';

  @override
  String get iconNameHelpFa => 'Ajuda FA';

  @override
  String get iconNameHelpFaOutline => 'Ajuda FA Contorno';

  @override
  String get iconNameListFa => 'Lista FA';

  @override
  String get iconNameGridFa => 'Grelha FA';

  @override
  String get iconNameSlidersFa => 'Deslizadores FA';

  @override
  String get iconNameTvFa => 'TV FA';

  @override
  String get iconNameMonitorFa => 'Monitor FA';

  @override
  String get iconNameDesktopFa => 'Escritorio FA';

  @override
  String get iconNameBrightnessFa => 'Brilho FA';

  @override
  String get iconNameNightModeFa => 'Noche Modo FA';

  @override
  String get iconNameLightFa => 'Luz FA';

  @override
  String get iconNameLightFaOutline => 'Luz FA Contorno';

  @override
  String get iconNameFlashFa => 'Flash FA';

  @override
  String get iconNameFullscreenFa => 'Ecrã completa FA';

  @override
  String get iconNameExitFullscreenFa => 'Exit Ecrã completa FA';

  @override
  String get iconNameZoomInFa => 'Acercar FA';

  @override
  String get iconNameZoomOutFa => 'Alejar FA';

  @override
  String get iconNameSubtitlesFa => 'Legendas FA';

  @override
  String get iconNamePictureInPictureFa => 'Imagem en imagem FA';

  @override
  String get iconNameColorFa => 'Cor FA';

  @override
  String get iconNamePaintFa => 'Pintura FA';

  @override
  String get iconNameInputFa => 'Entrada FA';

  @override
  String get iconNameWifiFa => 'WiFi FA';

  @override
  String get iconNameBluetoothFa => 'Bluetooth FA';

  @override
  String get iconNameUsbFa => 'USB FA';

  @override
  String get iconNameEthernetFa => 'Ethernet FA';

  @override
  String get iconNameGamepadFa => 'Comando FA';

  @override
  String get iconNameBroadcastFa => 'Emisión FA';

  @override
  String get iconNameSatelliteFa => 'Satellite FA';

  @override
  String get iconNameAntennaFa => 'Antenna FA';

  @override
  String get iconNameNetworkFa => 'Red FA';

  @override
  String get iconNameCloudFa => 'Nube FA';

  @override
  String get iconNameStarFa => 'Estrella FA';

  @override
  String get iconNameStarFaOutline => 'Estrella FA contorno';

  @override
  String get iconNameHeartFa => 'Corazón FA';

  @override
  String get iconNameHeartFaOutline => 'Heart FA Contorno';

  @override
  String get iconNameBookmarkFa => 'Marcador FA';

  @override
  String get iconNameBookmarkFaOutline => 'Marcador FA contorno';

  @override
  String get iconNameFlagFa => 'Bandera FA';

  @override
  String get iconNameClockFa => 'Reloj FA';

  @override
  String get iconNameClockFaOutline => 'Clock FA Contorno';

  @override
  String get iconNameBellFa => 'Campana FA';

  @override
  String get iconNameBellFaOutline => 'Bell FA Contorno';

  @override
  String get iconNameTimerFa => 'Temporizador FA';

  @override
  String get iconNameLockFa => 'Bloqueo FA';

  @override
  String get iconNameUnlockFa => 'Desbloquear FA';

  @override
  String get iconNameGalleryFa => 'Galería FA';

  @override
  String get iconNameImagesFa => 'Imagens FA';

  @override
  String get iconNameImageFa => 'Imagem FA';

  @override
  String get iconNameVideoFileFa => 'Ficheiro de video FA';

  @override
  String get iconNameAudioFileFa => 'Ficheiro de áudio FA';

  @override
  String get iconNamePlayOutlineFa => 'Reproduzir Contorno FA';

  @override
  String get iconNamePlaySimpleFa => 'Reproduzir simple FA';

  @override
  String get iconNamePauseSimpleFa => 'Pausa simple FA';

  @override
  String get iconNameStopSimpleFa => 'Parar simple FA';

  @override
  String get iconNameRecordFa => 'Grabar FA';

  @override
  String get iconNameStopCircleFa => 'Parar Círculo FA';

  @override
  String get iconNameLoadingFa => 'Cargando FA';

  @override
  String get iconNameTextFa => 'Texto FA';

  @override
  String get iconNameTextSizeFa => 'Texto Tamanho FA';

  @override
  String get iconNameLanguageFa => 'Idioma FA';

  @override
  String get iconNameGlobeFa => 'Globo FA';

  @override
  String get iconNameSubtitlesAltFa => 'Legendas Alt FA';

  @override
  String get iconNameSubtitlesAltOutlineFa => 'Legendas Alt Contorno FA';

  @override
  String get iconNameChannelUpFa => 'Canal Cima FA';

  @override
  String get iconNameChannelDownFa => 'Canal Baixo FA';

  @override
  String get iconNamePageUpFa => 'Página Cima FA';

  @override
  String get iconNamePageDownFa => 'Página Baixo FA';

  @override
  String get iconNameGuideFa => 'Guía FA';

  @override
  String get iconNameGridViewFa => 'Grelha Vista FA';

  @override
  String get iconNameGridAltFa => 'Grelha Alt FA';

  @override
  String get iconNameScheduleFa => 'Programación FA';

  @override
  String get iconNameCalendarFa => 'Calendario FA';

  @override
  String get iconNameRedButtonFa => 'Rojo Botão FA';

  @override
  String get iconNameButtonOutlineFa => 'Botão Contorno FA';

  @override
  String get iconNameSquareButtonFa => 'Quadrado Botão FA';

  @override
  String get iconNameSquareOutlineFa => 'Quadrado Contorno FA';

  @override
  String get iconNameDotCircleFa => 'Punto Círculo FA';

  @override
  String get iconNameToolsFa => 'Herramientas FA';

  @override
  String get iconNameScrewdriverFa => 'Distornillador FA';

  @override
  String get iconNameHammerFa => 'Martillo FA';

  @override
  String get iconNameToolboxFa => 'Caja de herramientas FA';

  @override
  String get iconNameCogFa => 'Engrane FA';

  @override
  String get iconNameAdjustFa => 'Ajustar FA';

  @override
  String get iconNameFilterFa => 'Filtro FA';

  @override
  String get iconNameSortDownFa => 'Ordenar Baixo FA';

  @override
  String get iconNameSortUpFa => 'Ordenar Cima FA';

  @override
  String get iconNameSleepFa => 'Reposo FA';

  @override
  String get iconNameTimerStartFa => 'Temporizador Iniciar FA';

  @override
  String get iconNameTimerHalfFa => 'Temporizador Mitad FA';

  @override
  String get iconNameTimerEndFa => 'Temporizador Fin FA';

  @override
  String get iconNameStopwatchFa => 'Cronómetro FA';

  @override
  String get iconNameAlarmFa => 'Alarma FA';

  @override
  String get iconNameCropAltFa => 'Recortar Alt FA';

  @override
  String get iconNameCropFa => 'Recortar FA';

  @override
  String get iconNameSquareFullFa => 'Quadrado Completo FA';

  @override
  String get iconNameFullscreenAltFa => 'Ecrã completa Alt FA';

  @override
  String get iconNameZoomPlusFa => 'Zoom Mais FA';

  @override
  String get iconNameZoomMinusFa => 'Zoom Menos FA';

  @override
  String get iconNameMusicNoteFa => 'Música Nota FA';

  @override
  String get iconNameCdFa => 'CD FA';

  @override
  String get iconNameVinylFa => 'Vinilo FA';

  @override
  String get iconNameRssFa => 'RSS FA';

  @override
  String get iconNameMagicFa => 'Mágico FA';

  @override
  String get iconNameFingerprintFa => 'Huella FA';

  @override
  String get iconNameUserFa => 'Usuario FA';

  @override
  String get iconNameUsersFa => 'Usuarios FA';

  @override
  String get iconNameChildModeFa => 'Niño Modo FA';

  @override
  String get iconNameCastFa => 'Transmitir FA';

  @override
  String get iconNameStreamFa => 'Flujo FA';

  @override
  String get iconNameSignalFa => 'Sinal FA';

  @override
  String get iconNameFeedFa => 'Feed FA';

  @override
  String get iconNameCircleArrowUpFa => 'Círculo Seta Cima FA';

  @override
  String get iconNameCircleArrowDownFa => 'Círculo Seta Baixo FA';

  @override
  String get iconNameCircleArrowLeftFa => 'Círculo Seta Esquerda FA';

  @override
  String get iconNameCircleArrowRightFa => 'Círculo Seta Direita FA';

  @override
  String get iconNameLongArrowUpFa => 'Largo Seta Cima FA';

  @override
  String get iconNameLongArrowDownFa => 'Largo Seta Baixo FA';

  @override
  String get iconNameLongArrowLeftFa => 'Largo Seta Esquerda FA';

  @override
  String get iconNameLongArrowRightFa => 'Largo Seta Direita FA';

  @override
  String get iconNamePlusFa => 'Mais FA';

  @override
  String get iconNameMinusFa => 'Menos FA';

  @override
  String get iconNamePlusCircleFa => 'Mais Círculo FA';

  @override
  String get iconNameMinusCircleFa => 'Menos Círculo FA';

  @override
  String get iconNamePlusSquareFa => 'Mais Quadrado FA';

  @override
  String get iconNameMinusSquareFa => 'Menos Quadrado FA';

  @override
  String get iconNameTimesFa => 'Veces FA';

  @override
  String get iconNameTimesCircleFa => 'Veces Círculo FA';

  @override
  String get iconNameBatteryFullFa => 'Batería Completo FA';

  @override
  String get iconNameBattery34Fa => 'Batería 3/4 FA';

  @override
  String get iconNameBatteryHalfFa => 'Batería Mitad FA';

  @override
  String get iconNameBattery14Fa => 'Batería 1/4 FA';

  @override
  String get iconNameBatteryEmptyFa => 'Batería Empty FA';

  @override
  String get iconNameChargingFa => 'Cargando FA';

  @override
  String get iconNameCloudSunFa => 'Nube Sol FA';

  @override
  String get iconNameCloudMoonFa => 'Nube Luma FA';

  @override
  String get iconNameRainFa => 'Lluvia FA';

  @override
  String get iconNameSnowflakeFa => 'Copo FA';

  @override
  String get iconNameFireFa => 'Fuego FA';

  @override
  String get iconNameTemperatureFa => 'Temperatura FA';

  @override
  String get iconNameBoxFa => 'Caja FA';

  @override
  String get iconNameGiftFa => 'Regalo FA';

  @override
  String get iconNameTrophyFa => 'Trofeo FA';

  @override
  String get iconNameCrownFa => 'Corona FA';

  @override
  String get iconNameGemFa => 'Gema FA';

  @override
  String get unknownLabel => 'Desconhecido';

  @override
  String get selectedFilesLabel => 'ficheiro(s) selecionado(s)';

  @override
  String get folderNotFoundOrInaccessible =>
      'Pasta não encontrada o inaccesible.';

  @override
  String get importedRemoteDefaultName => 'MandoImportado';

  @override
  String get demoRemoteName => 'Comando demo';

  @override
  String get protocolFieldsInvalid =>
      'Rellena os campos obrigatórios do protocolo e asegúrate de que a frecuencia sea 15k–60k se se define.';

  @override
  String get unknownProtocolSelected =>
      'Se seleccionó un protocolo desconhecido.';

  @override
  String get continueSectionTitle => 'Continue';

  @override
  String get continueSectionSubtitle => 'Pick up where you left off.';

  @override
  String get continueLastRemoteTitle => 'Last remote';

  @override
  String get continueLastMacroTitle => 'Last macro';

  @override
  String get continueLastIrFinderHitTitle => 'Last IR Finder hit';

  @override
  String get continueTargetUnavailable => 'That item is no longer available.';

  @override
  String get continueUniversalPowerAllBrands => 'All brands';

  @override
  String get untitledMacro => 'Untitled Macro';

  @override
  String get pinnedRemotesTitle => 'Pinned remotes';

  @override
  String get pinnedRemotesSubtitle =>
      'Keep your most important remotes one tap away.';

  @override
  String get recentlyUsedRemotesTitle => 'Recently used';

  @override
  String get recentlyUsedRemotesSubtitle =>
      'Jump back into the remotes you opened most recently.';

  @override
  String get pinRemote => 'Pin remote';

  @override
  String get unpinRemote => 'Unpin remote';

  @override
  String get pinRemoteSubtitle =>
      'Keep this remote at the top for faster access.';

  @override
  String get remoteAddedToPinned => 'Remote pinned.';

  @override
  String get remoteRemovedFromPinned => 'Remote removed from pinned.';

  @override
  String get homeDeviceControlsTitle => 'Quick controls';

  @override
  String get homeDeviceControlsSubtitle =>
      'Power, mute, and volume without opening a remote.';

  @override
  String get homeDeviceControlsEmptySubtitle =>
      'Set up power, mute, and volume buttons in Device Controls.';

  @override
  String get showDeviceControlsOnHome => 'Show quick controls on home';

  @override
  String get showDeviceControlsOnHomeSubtitle =>
      'Show the compact Power, Mute, and Volume row on the main screen.';

  @override
  String get homeDeviceControlsShown => 'Quick controls shown on home.';

  @override
  String get homeDeviceControlsHidden => 'Quick controls hidden from home.';

  @override
  String get power => 'Power';

  @override
  String get mute => 'Mute';

  @override
  String get volumeUp => 'Vol +';

  @override
  String get volumeDown => 'Vol -';

  @override
  String get manage => 'Manage';

  @override
  String get hide => 'Hide';

  @override
  String get lastActionTitle => 'Last action';

  @override
  String lastActionSent(String title) {
    return 'Sent $title';
  }

  @override
  String lastActionSentTo(String remoteName, String title) {
    return 'Sent $remoteName -> $title';
  }

  @override
  String get repeatAction => 'Repeat';

  @override
  String get globalSearchTitle => 'Search everything';

  @override
  String get globalSearchNoResults => 'No results found.';

  @override
  String get globalSearchTypeRemote => 'REMOTE';

  @override
  String get globalSearchTypeButton => 'BUTTON';

  @override
  String get globalSearchTypeMacro => 'MACRO';

  @override
  String get learningModeCaptureFailed => 'A captura de aprendizagem falhou.';

  @override
  String get learningModeReplaySent => 'Sinal aprendido repetido.';

  @override
  String get learningModeReplayFailed =>
      'O sinal aprendido não pôde ser reproduzido.';

  @override
  String get learningModeNoRemotesAvailable =>
      'Ainda não há controles remotos salvos.';

  @override
  String get learningModeChooseRemoteTitle => 'Escolha um controle remoto';

  @override
  String get learningModeNewRemoteTitle => 'Crie um novo controle remoto';

  @override
  String get learningModeSaveSuccess => 'Botão aprendido salvo.';

  @override
  String get learningModeSaveFailed => 'O botão aprendido não pôde ser salvo.';

  @override
  String get remoteSetupIntro =>
      'Escolha primeiro um nome e um layout. Depois você poderá adicionar botões.';

  @override
  String get startWithDefault => 'Começar com o padrão';

  @override
  String get browseGithubStore => 'Explorar GitHub Store';

  @override
  String get addFirstButton => 'Adicionar primeiro botão';

  @override
  String get moreWaysToStart => 'Mais formas de começar';

  @override
  String get unsavedRemoteSetupChangesMessage =>
      'Descartar esta nova configuração do comando e sair deste ecrã?';

  @override
  String get unsavedRemoteStudioChangesMessage =>
      'Descartar as alterações do comando e sair deste ecrã?';

  @override
  String get firstButtonAdded => 'Primeiro botão adicionado.';

  @override
  String get iconColorTitle => 'Cor do ícone';

  @override
  String get iconColorHelper =>
      'Escolha uma cor para o símbolo que continue visível sobre o fundo do botão.';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorDeepPurple => 'Roxo escuro';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorLightBlue => 'Azul claro';

  @override
  String get colorCyan => 'Ciano';

  @override
  String get colorTeal => 'Verde-azulado';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorLightGreen => 'Verde claro';

  @override
  String get colorLime => 'Lima';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorAmber => 'Âmbar';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorDeepOrange => 'Laranja escuro';

  @override
  String get colorBrown => 'Castanho';

  @override
  String get colorGrey => 'Cinzento';

  @override
  String get colorBlueGrey => 'Cinzento azulado';

  @override
  String get colorBlack => 'Preto';

  @override
  String get colorWhite => 'Branco';

  @override
  String buttonColorSemantics(Object colorName) {
    return 'Cor do botão $colorName';
  }

  @override
  String buttonColorSemanticsSelected(Object colorName) {
    return 'Cor do botão $colorName, selecionada';
  }

  @override
  String iconColorSemantics(Object colorName) {
    return 'Cor do ícone $colorName';
  }

  @override
  String iconColorSemanticsSelected(Object colorName) {
    return 'Cor do ícone $colorName, selecionada';
  }

  @override
  String get usbDevInfoAppTitle => 'Info USB';

  @override
  String get navigationErrorTitle => 'Erro de navegação';

  @override
  String get homeHistoryTooltip => 'Histórico';

  @override
  String get homeSettingsTooltip => 'Definições';

  @override
  String get homeSearchHint =>
      'Pesquisar fornecedor, produto, VID:PID, caminho do dispositivo…';

  @override
  String get homeClearSearchTooltip => 'Limpar';

  @override
  String get homeInputDeviceLabel => 'Dispositivo de entrada';

  @override
  String get homeUsbDeviceLabel => 'Dispositivo USB';

  @override
  String get homeUnknownVendor => 'Fornecedor desconhecido';

  @override
  String get homeSysfsTopology => 'Topologia sysfs';

  @override
  String get homePermissionGranted => 'Permissão concedida';

  @override
  String get homeNeedsPermission => 'Precisa de permissão';

  @override
  String get homeHiddenTopology => 'Topologia oculta';

  @override
  String get homeInputPath => 'Caminho de entrada';

  @override
  String get homeNoUsbDevicesTitle => 'Nenhum dispositivo USB detetado';

  @override
  String get homeNoUsbDevicesBody =>
      'Ligue um dispositivo USB (OTG) ou um acessório USB e depois puxe para atualizar.\n\nDica: conceda permissão por dispositivo para ler cadeias, analisar descritores em bruto e enumerar configurações, interfaces e endpoints completos.';

  @override
  String homeInterfacesCount(int count) {
    return '$count interfaces';
  }

  @override
  String homeInputSourcesLabel(Object sources) {
    return 'Entrada: $sources';
  }

  @override
  String homeFailedToLoad(Object error) {
    return 'Falha ao carregar dispositivos:\n$error';
  }

  @override
  String get historyScreenTitle => 'Histórico';

  @override
  String get historyClearAllTooltip => 'Limpar tudo';

  @override
  String get historyPreviouslyInspectedTitle =>
      'Dispositivos inspecionados anteriormente';

  @override
  String get historyNothingRecordedYet => 'Ainda nada registado';

  @override
  String get historyRecordedSingle => '1 item registado';

  @override
  String historyRecordedCount(int count) {
    return '$count itens registados';
  }

  @override
  String get historyOpenDevicePageHint =>
      'Abra uma página de informações do dispositivo para o registar aqui.';

  @override
  String get historySwipeToDeleteHint =>
      'Deslize para a esquerda para eliminar. Use Desfazer para restaurar.';

  @override
  String get historySearchHint => 'Pesquisar nome, VID:PID, série, caminho…';

  @override
  String get historyRemovedMessage => 'Removido do histórico';

  @override
  String get historyClearDialogTitle => 'Limpar histórico?';

  @override
  String get historyClearDialogBody =>
      'Isto irá remover todos os dispositivos registados.';

  @override
  String get historyClearAllAction => 'Limpar tudo';

  @override
  String get historyConnected => 'Ligado';

  @override
  String get historyNotConnected => 'Desligado';

  @override
  String get historyPermissionLabel => 'Permissão';

  @override
  String get historyActionsTooltip => 'Ações';

  @override
  String get historyNoMatchesTitle => 'Sem resultados';

  @override
  String get historyNoHistoryTitle => 'Ainda sem histórico';

  @override
  String get historyNoMatchesBody => 'Experimente outro termo de pesquisa.';

  @override
  String get historyNoHistoryBody =>
      'Abra uma página de informações do dispositivo para registar aqui uma entrada.';

  @override
  String historyQueryLabel(Object query) {
    return 'Consulta: \"$query\"';
  }

  @override
  String historyFailedToLoad(Object error) {
    return 'Falha ao carregar o histórico:\n$error';
  }

  @override
  String get usbSettingsSupportSubtitle =>
      'Mantenha esta app rápida, livre e mantida';

  @override
  String get usbSettingsSupportBody =>
      'Sem anúncios, sem rastreio, totalmente offline. O seu apoio ajuda a financiar a manutenção, correções de compatibilidade USB e atualizações mais rápidas da base de dados USB IDs.';

  @override
  String get usbSettingsSupportPillLightweight => 'Leve';

  @override
  String get usbUseDynamicColorsSubtitle =>
      'Faz corresponder a paleta Material You no Android 12+. Desative para usar a paleta da app.';

  @override
  String get usbAboutFailedToOpenLink => 'Falha ao abrir a ligação';

  @override
  String usbAboutVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get usbAboutLinksTitle => 'Ligações';

  @override
  String get usbAboutLinksSubtitle => 'Repositório, problemas e donativos';

  @override
  String get usbAboutRepositoryTitle => 'Repositório';

  @override
  String get usbAboutReportIssueTitle => 'Reportar um problema';

  @override
  String get usbAboutIssuesLinkCopied => 'Ligação dos problemas copiada';

  @override
  String get usbAboutDonateTitle => 'Doar via Liberapay';

  @override
  String get usbAboutLiberapayLinkCopied => 'Ligação Liberapay copiada';

  @override
  String get usbAboutWhatThisAppIsTitle => 'O que é esta app';

  @override
  String get usbAboutWhatThisAppIsSubtitle => 'Utilitário de inspeção USB';

  @override
  String get usbAboutWhatThisAppIsBody =>
      'O USBDevInfo enumera dispositivos OTG/USB host, mostra descritores e detalhes de classe/protocolo, resolve VID/PID usando uma base de dados USB IDs offline e regista o histórico de ligação. Sem contas, sem rastreio, sem anúncios.';

  @override
  String get usbAboutUsbHostPill => 'USB host';

  @override
  String get usbAboutDescriptorsPill => 'Descritores';

  @override
  String get usbAboutOfflineUsbIdsPill => 'USB IDs offline';

  @override
  String get usbAboutBuildInformationTitle => 'Informações de compilação';

  @override
  String get usbAboutBuildInformationSubtitle =>
      'Versão, pacote e modo de compilação';

  @override
  String get usbAboutAppLabel => 'App';

  @override
  String get usbAboutVersionLabel => 'Versão';

  @override
  String get usbAboutPackageLabel => 'Pacote';

  @override
  String get usbAboutBuildLabel => 'Compilação';

  @override
  String get usbAboutBuildModeRelease => 'Release';

  @override
  String get usbAboutBuildModeProfile => 'Perfil';

  @override
  String get usbAboutBuildModeDebug => 'Debug';

  @override
  String get usbAboutOtherAppsTitle => 'Outras apps da KaijinLab';

  @override
  String get usbAboutOtherAppsSubtitle =>
      'Mais ferramentas ligadas à segurança e ao hardware';

  @override
  String get usbAboutOpenGithubRepository => 'Abrir repositório no GitHub';

  @override
  String get usbAboutLegalTitle => 'Informação legal';

  @override
  String get usbAboutLegalSubtitle => 'Licenças open source e agradecimentos';

  @override
  String get usbAboutViewThirdPartyLicenses =>
      'Ver licenças de dependências de terceiros';

  @override
  String get usbAboutCopyBuildDetailsTitle => 'Copiar detalhes da compilação';

  @override
  String get usbAboutCopyBuildDetailsSubtitle =>
      'Versão + pacote + modo de compilação';

  @override
  String get usbAboutBuildDetailsCopied => 'Detalhes da compilação copiados';

  @override
  String usbAboutCopyright(int year) {
    return '© $year KaijinLab • Software open source';
  }

  @override
  String get unavailable => 'Indisponível';

  @override
  String get deviceInfoTitle => 'Informações do dispositivo';

  @override
  String get deviceAdvancedRawViewTooltip => 'Visualização bruta avançada';

  @override
  String get deviceExportRawDumpTooltip => 'Exportar dump bruto';

  @override
  String get deviceUnableToReadDetails =>
      'Não foi possível ler os detalhes do dispositivo.';

  @override
  String get deviceAudioClassDescriptorsTitle =>
      'Descritores de classe de áudio';

  @override
  String get deviceVideoClassDescriptorsTitle =>
      'Descritores de classe de vídeo';

  @override
  String get deviceCdcSerialDescriptorsTitle => 'Descritores CDC / série';

  @override
  String get deviceHubDescriptorsTitle => 'Descritores de hub';

  @override
  String get deviceBosCapabilitiesTitle => 'BOS & capabilities';

  @override
  String get deviceIdentityTitle => 'Identidade';

  @override
  String get deviceIdentitySubtitle =>
      'IDs, cadeias de fornecedor/produto e continuidade';

  @override
  String get deviceVendorIdLabel => 'ID do fornecedor';

  @override
  String get deviceProductIdLabel => 'ID do produto';

  @override
  String get deviceVendorLabel => 'Fornecedor';

  @override
  String get deviceProductLabel => 'Produto';

  @override
  String get deviceChipsetFamilyLabel => 'Família do chipset';

  @override
  String get deviceChipsetBasisLabel => 'Chipset basis';

  @override
  String get deviceLikelyFunctionLabel => 'Função provável';

  @override
  String get deviceFunctionBasisLabel => 'Function basis';

  @override
  String get deviceSerialLabel => 'Número de série';

  @override
  String get deviceStableIdentityLabel => 'Identidade estável';

  @override
  String get deviceIdentityConfidenceLabel => 'Confiabilidade da identidade';

  @override
  String get deviceIdentityStrategyLabel => 'Estratégia de identidade';

  @override
  String get devicePhysicalLocationLabel => 'Localização física';

  @override
  String get deviceInterfaceFingerprintLabel => 'Impressão da interface';

  @override
  String get devicePathContinuityLabel => 'Continuidade do caminho';

  @override
  String get deviceNoPreviousPathRecorded => 'No previous device path recorded';

  @override
  String get devicePreviousPathsLabel => 'Caminhos anteriores';

  @override
  String get deviceUsbSpecificationTitle => 'Especificação USB';

  @override
  String get deviceUsbSpecificationSubtitle =>
      'Versão, velocidade, classe/protocolo';

  @override
  String get deviceUsbVersionLabel => 'Versão USB';

  @override
  String get deviceSpeedLabel => 'Velocidade';

  @override
  String get deviceDeviceClassLabel => 'Classe do dispositivo';

  @override
  String get deviceSubclassLabel => 'Subclasse';

  @override
  String get deviceProtocolLabel => 'Protocolo';

  @override
  String get deviceInterfacesLabel => 'Interfaces';

  @override
  String get deviceConfigurationsLabel => 'Configurações';

  @override
  String get deviceLocationTitle => 'Localização';

  @override
  String get deviceLocationSubtitle =>
      'Identificadores do Android e dicas do barramento';

  @override
  String get devicePathLabel => 'Caminho do dispositivo';

  @override
  String get deviceAndroidDeviceIdLabel => 'deviceId do Android';

  @override
  String get devicePortNumberLabel => 'Número da porta';

  @override
  String get deviceTypeLabel => 'Tipo';

  @override
  String get deviceTypeInputManager =>
      'Dispositivo de entrada (teclado/rato via InputManager)';

  @override
  String get deviceTypeSysfs => 'Entrada da topologia USB (sysfs)';

  @override
  String get deviceTypeUsbManager => 'Dispositivo USB (UsbManager)';

  @override
  String get deviceTopologyTitle => 'Topologia';

  @override
  String get deviceTopologySubtitle =>
      'Layout do barramento, cadeia, pai e irmãos';

  @override
  String get deviceSourceLabel => 'Source';

  @override
  String get deviceSysfsNameLabel => 'Sysfs name';

  @override
  String get deviceSysfsPathLabel => 'Sysfs path';

  @override
  String get deviceDeviceNodeLabel => 'Device node';

  @override
  String get deviceParentLabel => 'Parent';

  @override
  String get deviceUpstreamHubLabel => 'Upstream hub';

  @override
  String get deviceBusNumberLabel => 'Bus number';

  @override
  String get deviceDeviceNumberLabel => 'Device number';

  @override
  String get deviceTreeDepthLabel => 'Tree depth';

  @override
  String get devicePortChainLabel => 'Port chain';

  @override
  String get deviceDevpathLabel => 'Devpath';

  @override
  String get deviceAuthorizedLabel => 'Authorized';

  @override
  String get deviceRemovableLabel => 'Removable';

  @override
  String get deviceMaxChildLabel => 'Max child';

  @override
  String get devicePathShortLabel => 'Path';

  @override
  String get deviceSiblingDevicesTitle => 'Sibling devices';

  @override
  String get deviceDownstreamChildrenTitle => 'Downstream children';

  @override
  String get deviceDescriptorTitle => 'Descritor do dispositivo';

  @override
  String get deviceDescriptorSubtitle => 'Campos brutos do descritor USB';

  @override
  String get deviceShowDescriptorFields => 'Mostrar campos do descritor';

  @override
  String get deviceUsbSpecBcdLabel => 'USB spec (bcdUSB)';

  @override
  String get deviceReleaseBcdLabel => 'Device release (bcdDevice)';

  @override
  String get deviceEp0MaxPacketLabel => 'EP0 max packet';

  @override
  String get deviceNumConfigurationsLabel => 'Num configurations';

  @override
  String get deviceIManufacturerLabel => 'iManufacturer';

  @override
  String get deviceIProductLabel => 'iProduct';

  @override
  String get deviceISerialNumberLabel => 'iSerialNumber';

  @override
  String get deviceUsbAudioTitle => 'Áudio USB';

  @override
  String get deviceUsbAudioSubtitle =>
      'Metadados de endpoint do AudioManager / AudioDeviceInfo';

  @override
  String get deviceUsbAudioClassLabel => 'USB audio class';

  @override
  String get devicePlatformAudioApiLabel => 'Platform audio API';

  @override
  String get deviceAvailable => 'Available';

  @override
  String get deviceConnectedUsbAudioEndpointsLabel =>
      'Endpoints de áudio USB ligados';

  @override
  String get deviceMatchedEndpointsLabel => 'Endpoints correspondentes';

  @override
  String get deviceAudioManagerUnavailableNote =>
      'Os dados do AudioManager não estão disponíveis nesta versão do Android ou neste dispositivo.';

  @override
  String get deviceNoAudioEndpointMatchedNote =>
      'Ainda não foi possível associar nenhum endpoint AudioDeviceInfo a este dispositivo USB.';

  @override
  String get deviceAndroidNoMatchedAudioEndpointNote =>
      'O Android não indica nenhum endpoint de áudio USB correspondente para este dispositivo.';

  @override
  String get deviceUsbMidiTitle => 'MIDI USB';

  @override
  String get deviceUsbMidiSubtitle =>
      'Metadados de dispositivo e porta do MidiManager';

  @override
  String get deviceProbableUsbMidiInterfaceLabel =>
      'Interface USB MIDI provável';

  @override
  String get devicePlatformMidiApiLabel => 'API MIDI da plataforma';

  @override
  String get deviceConnectedMidiDevicesLabel => 'Dispositivos MIDI ligados';

  @override
  String get deviceMatchedMidiDevicesLabel =>
      'Dispositivos MIDI correspondentes';

  @override
  String get deviceMidiManagerUnavailableNote =>
      'Os dados do MidiManager não estão disponíveis nesta versão do Android ou neste dispositivo.';

  @override
  String get deviceDescriptorsLookLikeMidiNote =>
      'Os descritores USB parecem ser MIDI, mas o Android não expôs um dispositivo MidiManager correspondente.';

  @override
  String get deviceAndroidNoMatchedMidiDeviceNote =>
      'O Android não indica nenhum dispositivo MIDI correspondente para este dispositivo USB.';

  @override
  String get devicePowerTitle => 'Energia';

  @override
  String get devicePowerSubtitle => 'Orçamento de energia da configuração';

  @override
  String get deviceMaxPowerConfig0Label => 'Max power (config 0)';

  @override
  String get deviceConfigurationsTitle => 'Configurações';

  @override
  String get deviceConfigurationsSubtitle =>
      'Todas as configurações USB reportadas';

  @override
  String get deviceInterfacesEndpointsTitle => 'Interfaces e endpoints';

  @override
  String get deviceInterfacesEndpointsSubtitle =>
      'Descritores de interface e endpoint analisados';

  @override
  String get deviceInputDeviceTitle => 'Dispositivo de entrada';

  @override
  String get deviceInputDeviceSubtitle =>
      'Informações de teclado/rato do InputManager';

  @override
  String get deviceNameLabel => 'Name';

  @override
  String get deviceDescriptorLabel => 'Descritor';

  @override
  String get deviceExternalLabel => 'External';

  @override
  String get deviceSourcesLabel => 'Sources';

  @override
  String get deviceKeyboardTypeLabel => 'Keyboard type';

  @override
  String get deviceMotionRangesLabel => 'Motion ranges';

  @override
  String get deviceShowMotionRanges => 'Show motion ranges';

  @override
  String get deviceFrameworkLimitationsTitle =>
      'Limitações do framework Android';

  @override
  String get deviceFrameworkLimitationsSubtitle =>
      'O dispositivo está presente, mas o Android esconde parte dele ou não a expõe';

  @override
  String get devicePermissionDiagnosticsTitle => 'Diagnóstico de permissões';

  @override
  String get devicePermissionDiagnosticsSubtitle =>
      'Manifest, tempo de execução, estado USB, comportamento do Android e última falha';

  @override
  String get deviceLoadingDiagnostics => 'A carregar diagnóstico…';

  @override
  String get deviceShowPermissionDiagnostics => 'Show permission diagnostics';

  @override
  String get devicePermissionStateTemporary => 'Temporário';

  @override
  String get devicePermissionStatePermanent => 'Permanente';

  @override
  String get devicePermissionStateReenumerated => 'Reenumerado';

  @override
  String get devicePermissionStateNotInApp => 'Não disponível na app';

  @override
  String get devicePermissionStateRevoked => 'Revogado';

  @override
  String get deviceAndroidVersionLabel => 'Android version';

  @override
  String get deviceUsbDetailLabel => 'USB detail';

  @override
  String get deviceMicrophoneManifestLabel => 'Microphone manifest';

  @override
  String get deviceMicrophoneRuntimeLabel => 'Microphone runtime';

  @override
  String get deviceCameraManifestLabel => 'Camera manifest';

  @override
  String get deviceCameraRuntimeLabel => 'Camera runtime';

  @override
  String get deviceAndroidBehaviorLabel => 'Android behavior';

  @override
  String get deviceLastFailureReasonLabel => 'Last failure reason';

  @override
  String get deviceNoneRecorded => 'None recorded';

  @override
  String get deviceLastFailureDetailLabel => 'Last failure detail';

  @override
  String get deviceLastFailureTimeLabel => 'Last failure time';

  @override
  String get deviceWhyDataUnavailableTitle => 'Why data is unavailable';

  @override
  String get deviceWhyDataUnavailableSubtitle =>
      'Limitação exata do Android ou do dispositivo para campos ocultos';

  @override
  String get deviceReconnectDiffTitle => 'Diferença após religação';

  @override
  String get deviceReconnectDiffSubtitle =>
      'Dispositivo atual comparado com o estado capturado anteriormente';

  @override
  String get deviceStateTitle => 'Estado do dispositivo';

  @override
  String get deviceStateSubtitle =>
      'Configuração ativa, bits de estado e definições alternativas';

  @override
  String get deviceActiveConfigurationLabel => 'Active configuration';

  @override
  String get deviceStatusLabel => 'Device status';

  @override
  String get deviceSelfPoweredLabel => 'Self-powered';

  @override
  String get deviceRemoteWakeupLabel => 'Remote wakeup';

  @override
  String get deviceInterfaceAlternateSettingsTitle =>
      'Definições alternativas da interface';

  @override
  String get deviceStringDescriptorsTitle => 'Descritores de cadeia';

  @override
  String get deviceStringDescriptorsSubtitle =>
      'Idiomas e iManufacturer/iProduct/iSerial + iInterface';

  @override
  String get deviceLanguagesLabel => 'Languages';

  @override
  String get devicePreferredLabel => 'Preferred';

  @override
  String get deviceDeviceStringsTitle => 'Device strings';

  @override
  String get deviceManufacturerLabel => 'Manufacturer';

  @override
  String get deviceInterfaceStringsTitle => 'Strings da interface';

  @override
  String get deviceDescriptorTreeTitle => 'Árvore de descritores';

  @override
  String get deviceShowDescriptors => 'Mostrar descritores';

  @override
  String get deviceHidReportDescriptorsTitle => 'Descritores de relatório HID';

  @override
  String get devicePermissionRequiredTitle => 'Permissão necessária';

  @override
  String get devicePermissionRequiredBody =>
      'Para ler cadeias (fornecedor/produto/número de série), analisar descritores brutos e obter descritores de relatórios HID, o Android exige uma permissão por dispositivo.';

  @override
  String get deviceCameraPermissionRequiredForUsbVideo =>
      'Camera permission is required for USB video devices on this Android version.';

  @override
  String get devicePermissionNotGranted => 'Permissão não concedida';

  @override
  String get deviceGrantPermission => 'Conceder permissão';

  @override
  String get deviceAdvancedRawViewTitle => 'Visualização bruta avançada';

  @override
  String get deviceDescriptorNodesLabel => 'Nós do descritor';

  @override
  String get deviceControlTransfersLabel => 'Transferências de controlo';

  @override
  String get deviceHidReportDumpsLabel => 'Dumps de relatórios HID';

  @override
  String get deviceControlTransfersTitle => 'Transferências de controlo';

  @override
  String get deviceControlTransfersSubtitle =>
      'Raw setup/result records from direct USB control reads';

  @override
  String get deviceDescriptorsSideBySideTitle => 'Descritores lado a lado';

  @override
  String get deviceDescriptorsSideBySideSubtitle =>
      'Campos analisados ao lado dos bytes brutos do descritor';

  @override
  String get deviceHidReportDumpsTitle => 'Dumps de relatórios HID';

  @override
  String get deviceHidReportDumpsSubtitle =>
      'Hex do descritor de relatório com resumo analisado';

  @override
  String get deviceAdvancedDataUnavailableTitle => 'Advanced data unavailable';

  @override
  String get deviceAdvancedDataUnavailableSubtitle =>
      'Não há dados brutos de transferências de controlo nem descritores disponíveis para este dispositivo.';

  @override
  String get deviceGrantPermissionReconnectNote =>
      'Grant USB permission and reconnect the device if you want Android to expose direct descriptor and transfer data.';

  @override
  String get deviceExportFormatJson => 'Carga JSON';

  @override
  String get deviceExportFormatReport => 'Relatório de texto simples';

  @override
  String get deviceExportFormatRawHex => 'Descritores hex brutos';

  @override
  String get deviceRawDumpExportTitle => 'Exportação de dump bruto';

  @override
  String get deviceRawDumpExportSubtitle =>
      'Exporte esta captura ao vivo diretamente sem usar o histórico.';

  @override
  String get deviceExportChipJson => 'JSON';

  @override
  String get deviceExportChipReport => 'Relatório';

  @override
  String get deviceExportChipRawHex => 'Hex bruto';

  @override
  String get deviceCopyAction => 'Copiar';

  @override
  String get deviceYes => 'Yes';

  @override
  String get deviceNo => 'No';

  @override
  String get deviceUsbPermissionLabel => 'USB permission';

  @override
  String get deviceMaxPowerShortLabel => 'Max power';

  @override
  String get devicePreviousCaptureLabel => 'the previous capture';

  @override
  String get deviceManifestStatusDeclared => 'Declared';

  @override
  String get deviceManifestStatusMissing => 'Missing';

  @override
  String get deviceRuntimeStatusGranted => 'Granted';

  @override
  String get deviceRuntimeStatusTemporarilyDenied => 'Temporarily denied';

  @override
  String get deviceRuntimeStatusPermanentlyDenied => 'Permanently denied';

  @override
  String get deviceRuntimeStatusNotRequired =>
      'Not required on this Android version';

  @override
  String get deviceIdentityConfidenceHigh => 'High';

  @override
  String get deviceIdentityConfidenceMedium => 'Medium';

  @override
  String get deviceIdentityConfidenceLow => 'Low';

  @override
  String get deviceIdentityStrategySerialNumber => 'Serial number';

  @override
  String get deviceIdentityStrategyPhysicalPort =>
      'Physical port + interface fingerprint';

  @override
  String get deviceIdentityStrategyInterfaceFingerprint =>
      'Impressão digital da interface';

  @override
  String get deviceIdentityStrategyModelFingerprint => 'Model fingerprint';

  @override
  String get historyDetailTitle => 'Detalhe do histórico';

  @override
  String get historyOpenLiveDeviceInfo =>
      'Abrir informações do dispositivo ao vivo';

  @override
  String get historyIdentitySubtitle => 'IDs e cadeias de fornecedor/produto';

  @override
  String get historyAdvancedDetailsNotCapturedTitle =>
      'Detalhes avançados não capturados';

  @override
  String get historyAdvancedDetailsNotCapturedBody =>
      'Esta entrada do histórico não inclui descritores brutos, cadeias nem relatórios HID. Estes campos exigem permissão USB no momento da captura.';

  @override
  String get historyRawDumpExportSubtitle =>
      'Exporte esta captura histórica diretamente a partir do histórico.';

  @override
  String deviceDescriptorsCount(int count) {
    return '$count descritor(es)';
  }

  @override
  String deviceReenumeratedAcrossPaths(int count) {
    return 'Re-enumerated across $count known path(s)';
  }

  @override
  String deviceAndroidVersionValue(Object sdk, Object release) {
    return 'SDK $sdk ($release)';
  }

  @override
  String deviceChangesDetectedCompared(int count, Object baseline) {
    return '$count change(s) detected compared with $baseline.';
  }

  @override
  String deviceShowingFirstRanges(int count) {
    return 'Showing first $count ranges.';
  }

  @override
  String deviceFrameworkLimitationsDetected(int count) {
    return '$count framework-related limitation(s) detected for this device.';
  }

  @override
  String deviceShowPermissionDiagnosticsWithUnavailableData(int count) {
    return 'Show permission diagnostics & unavailable data ($count)';
  }

  @override
  String deviceNoDifferencesDetected(Object baseline) {
    return 'No differences detected compared with $baseline.';
  }

  @override
  String deviceAltSettingValue(Object value) {
    return 'Alt $value';
  }

  @override
  String deviceShowingFirstInterfaces(int count) {
    return 'Showing first $count interfaces.';
  }

  @override
  String deviceShowingFirstInterfaceStrings(int count) {
    return 'Showing first $count interface strings.';
  }

  @override
  String deviceDescriptorsParsed(int count) {
    return '$count descritores analisados';
  }

  @override
  String deviceInterfacesCount(int count) {
    return '$count interface(s)';
  }

  @override
  String deviceCopiedToClipboard(Object title) {
    return '$title copied to clipboard.';
  }

  @override
  String deviceCaptureFrom(Object date, Object time) {
    return 'the capture from $date $time';
  }

  @override
  String get deviceInputSourcesLabel => 'Input sources';

  @override
  String deviceShowingFirstFields(int count) {
    return 'A mostrar apenas os primeiros $count campos.';
  }

  @override
  String deviceShowingFirstDescriptors(int count) {
    return 'A mostrar os primeiros $count descritores.';
  }

  @override
  String get settingsUsbBehaviorTitle => 'Comportamento USB';

  @override
  String get settingsUsbBehaviorSubtitle =>
      'Controla os avisos do sistema quando um dispositivo USB é ligado';

  @override
  String get settingsUsbOfferOnAttachTitle => 'Sugerir abertura ao ligar USB';

  @override
  String get settingsUsbOfferOnAttachSubtitle =>
      'Aparece no seletor do Android quando um dispositivo USB é ligado.';

  @override
  String get settingsUsbDisableAttachNote =>
      'Desative isto para impedir que o Android sugira o USBDevInfo ao ligar um dispositivo. A aplicação continuará a detetar dispositivos enquanto estiver aberta.';

  @override
  String get settingsAttachFilterScopeLabel => 'Âmbito do filtro de ligação';

  @override
  String get settingsAttachFilterScopeAllUsbDevices =>
      'Todos os dispositivos USB';

  @override
  String get settingsAttachLaunchBehaviorLabel => 'Comportamento ao ligar';

  @override
  String get settingsAttachLaunchBehaviorEnabled =>
      'Abrir apenas quando o Android iniciar explicitamente o USBDevInfo a partir do seletor USB';

  @override
  String get settingsAttachLaunchBehaviorDisabled =>
      'Alias do seletor desativado';

  @override
  String get settingsWhileAppOpenLabel => 'Enquanto a aplicação está aberta';

  @override
  String get settingsWhileAppOpenValue =>
      'Os eventos de ligação/desligação USB atualizam os dados do dispositivo sem forçar navegação';

  @override
  String get settingsBackupDataTitle => 'Cópia de segurança e dados';

  @override
  String get settingsBackupDataSubtitle =>
      'Exportar o histórico de dispositivos em JSON';

  @override
  String get settingsHistoryLabel => 'Histórico';

  @override
  String get settingsMostRecentLabel => 'Mais recente';

  @override
  String get settingsNoHistoryYet => 'Ainda sem histórico';

  @override
  String settingsHistoryRecordedCount(int count) {
    return '$count item(ns) registado(s)';
  }

  @override
  String get settingsBackupExportIncludes =>
      'A exportação inclui IDs de fabricante/produto, nomes resolvidos, cadeias de texto, classe/protocolo, carimbos de data/hora e detalhes avançados (descritores, configurações, interfaces, relatórios HID) quando a permissão foi concedida.';

  @override
  String get settingsExportJsonAction => 'Exportar JSON';

  @override
  String get settingsImportJsonAction => 'Importar JSON';

  @override
  String get settingsUsbIdsDatabaseTitle => 'Base de dados de IDs USB';

  @override
  String get settingsUsbIdsDatabaseSubtitle => 'Metadados e atualização';

  @override
  String deviceConfigurationTitle(Object id, Object suffix) {
    return 'Configuração $id$suffix';
  }

  @override
  String get deviceAttributesLabel => 'Atributos';

  @override
  String get deviceInterfacesSummaryTitle => 'Interfaces (resumo)';

  @override
  String deviceInterfaceShortLabel(Object id) {
    return 'IF $id';
  }

  @override
  String deviceInterfaceSummaryValue(Object classValue, Object endpointCount) {
    return 'Classe $classValue • EP $endpointCount';
  }

  @override
  String deviceInterfaceStringLabel(
    Object interfaceNumber,
    Object alternateSetting,
  ) {
    return 'IF $interfaceNumber (Alt $alternateSetting)';
  }

  @override
  String get deviceKeyboardChip => 'Teclado';

  @override
  String get deviceMouseChip => 'Rato';

  @override
  String deviceReportIdsChip(Object count) {
    return 'IDs de relatório: $count';
  }

  @override
  String deviceCollectionsChip(Object count) {
    return 'Coleções: $count';
  }

  @override
  String deviceUsagePagesChip(Object pages) {
    return 'Páginas de uso: $pages';
  }

  @override
  String get homeCapabilityAudio => 'Áudio';

  @override
  String get homeCapabilityVideo => 'Vídeo';

  @override
  String get homeCapabilityHid => 'HID';

  @override
  String get homeCapabilityMidi => 'MIDI';

  @override
  String get homeCapabilityStorage => 'Armazenamento';

  @override
  String get homeCapabilityHub => 'Hub';

  @override
  String get homeCapabilityCdc => 'CDC';

  @override
  String get homeCapabilityComposite => 'Composto';

  @override
  String get homeCapabilityInput => 'Entrada';

  @override
  String get settingsUsbIdsLocalVersionLabel => 'Versão local';

  @override
  String get settingsUsbIdsLocalDateLabel => 'Data local';

  @override
  String get settingsUsbIdsRemoteShaNotFetched =>
      'O SHA remoto ainda não foi obtido.';

  @override
  String get settingsUsbIdsInstalledShaAfterUpdate =>
      'O SHA instalado será guardado após uma atualização bem-sucedida.';

  @override
  String get settingsUsbIdsInstalledShaMatchesRemote =>
      'O SHA instalado corresponde ao remoto.';

  @override
  String get settingsUsbIdsInstalledShaDiffersRemote =>
      'O SHA instalado difere do remoto (atualização disponível).';

  @override
  String get settingsUsbIdsDetailsTitle => 'Detalhes';

  @override
  String get settingsUsbIdsInstalledShaLabel => 'SHA-256 instalado';

  @override
  String get settingsUsbIdsRemoteShaLabel => 'SHA-256 remoto';

  @override
  String get settingsUsbIdsShaMatchLabel => 'Correspondência SHA';

  @override
  String get settingsUsbIdsLastCheckedLabel => 'Última verificação';

  @override
  String get settingsUsbIdsUpdateHintLabel => 'Indicação de atualização';

  @override
  String get settingsUsbIdsUpdateHintAvailable => 'Disponível';

  @override
  String get settingsUsbIdsUpdateHintNone => 'Nenhuma';

  @override
  String get settingsUsbIdsAutoCheckTitle =>
      'Verificar atualizações automaticamente';

  @override
  String get settingsUsbIdsAutoCheckSubtitle =>
      'Verifica o ficheiro .sha256 remoto cerca de uma vez por semana.';

  @override
  String get settingsUpdateNow => 'Atualizar agora';

  @override
  String get settingsCheckNow => 'Verificar agora';

  @override
  String get settingsAboutSectionTitle => 'Sobre';

  @override
  String get settingsAboutSectionSubtitle =>
      'Informações da aplicação e legais';

  @override
  String settingsAboutAppTileTitle(Object appName, Object developer) {
    return '$appName - $developer';
  }

  @override
  String settingsAboutVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get settingsLicensesTitle => 'Licenças';

  @override
  String get settingsLicensesSubtitle => 'Licenças de código aberto';

  @override
  String get settingsReportIssueTitle => 'Comunicar um problema';

  @override
  String get settingsReportIssueSubtitle =>
      'Erros e pedidos de funcionalidades';

  @override
  String get settingsIssuesLinkCopied => 'Ligação para issues copiada';

  @override
  String get settingsNoHistoryToExport => 'Não há histórico para exportar.';

  @override
  String get settingsExportCopied =>
      'Exportação copiada para a área de transferência.';

  @override
  String settingsExportFailed(Object error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String get settingsImportUnsupportedFormat =>
      'Formato JSON não suportado. É esperado um array ou uma carga de exportação com schema=device_history_export_v1.';

  @override
  String get settingsImportNoValidHistoryEntries =>
      'Não foram encontradas entradas de histórico válidas.';

  @override
  String settingsImportedItems(int count) {
    return '$count item(ns) importado(s).';
  }

  @override
  String settingsImportFailed(Object error) {
    return 'Falha ao importar: $error';
  }

  @override
  String get settingsClearHistoryBodyDetailed =>
      'Isto removerá todos os dispositivos registados do armazenamento local.';

  @override
  String get settingsHistoryCleared => 'Histórico limpo.';

  @override
  String get settingsExportHistoryTitle => 'Exportar histórico';

  @override
  String settingsExportHistorySubtitle(int count) {
    return '$count item(ns) • JSON';
  }

  @override
  String get settingsExportFormatPretty => 'Formatado';

  @override
  String get settingsExportFormatCompact => 'Compacto';

  @override
  String get settingsExportSafeShareNote =>
      'Esta exportação é segura para partilhar para depuração, mas pode conter nomes/caminhos de dispositivos e números de série.';

  @override
  String get settingsImportHistoryTitle => 'Importar histórico';

  @override
  String get settingsImportHistorySubtitle =>
      'Cole uma carga exportada ou uma lista bruta de entradas';

  @override
  String get settingsImportSupportedFormats =>
      'Formatos suportados: carga device_history_export_v1 (recomendado) ou um array JSON bruto de mapas de histórico.';

  @override
  String get settingsImportHint => 'Cole o JSON aqui…';

  @override
  String get settingsImportAction => 'Importar';

  @override
  String get settingsImporting => 'A importar…';

  @override
  String get settingsImportReplacesHistoryNote =>
      'A importação substitui o histórico atual. Se tiver dúvidas, exporte primeiro.';

  @override
  String get settingsClipboardEmpty => 'A área de transferência está vazia.';

  @override
  String get settingsPasteJsonFirst => 'Cole primeiro o JSON.';

  @override
  String get pasteAction => 'Colar';

  @override
  String get donationFocusCompatTitle => 'Compatibilidade e permissões';

  @override
  String get donationFocusCompatSubtitle =>
      'Particularidades OEM, fluxos de permissões, casos-limite';

  @override
  String get donationFocusUsbIdsTitle =>
      'Atualizações da base de dados de IDs USB';

  @override
  String get donationFocusUsbIdsSubtitle =>
      'Parsing, atualidade e fiabilidade da atualização';

  @override
  String get donationFocusUiTitle => 'Aperfeiçoamento de UI/UX';

  @override
  String get donationFocusUiSubtitle => 'Clareza, rapidez, acessibilidade';

  @override
  String get donationFocusFeaturesTitle => 'Novas funcionalidades';

  @override
  String get donationFocusFeaturesSubtitle =>
      'Filtros, exportações, informações';

  @override
  String donationShareHeader(Object appName) {
    return 'Apoie $appName - Aplicação open source';
  }

  @override
  String donationShareFocusLine(Object title) {
    return 'Foco: $title';
  }

  @override
  String get donationShareChainBtc =>
      'Bitcoin (BTC) - envie apenas pela rede Bitcoin.';

  @override
  String get donationShareChainEth =>
      'Ethereum (ERC-20) - envie apenas pela mainnet do Ethereum.';

  @override
  String donationShareBtcAddress(Object address) {
    return 'Endereço BTC: $address';
  }

  @override
  String donationShareEthAddress(Object address) {
    return 'Endereço ETH: $address';
  }

  @override
  String donationShareRepo(Object url) {
    return 'Repositório: $url';
  }

  @override
  String get donationNoBrowserForLiberapay =>
      'Nenhum navegador disponível para abrir o Liberapay';

  @override
  String get donationFailedToOpenLiberapay =>
      'Não foi possível abrir o Liberapay no navegador';

  @override
  String donationErrorOpeningLiberapay(Object error) {
    return 'Erro ao abrir o Liberapay: $error';
  }

  @override
  String get donationThankYouTitle => 'Obrigado';

  @override
  String get donationThankYouBody =>
      'O seu apoio ajuda a manter esta aplicação gratuita, rápida e com manutenção ativa. Obrigado por apoiar software open source.';

  @override
  String get donationFocusTitle => 'Foco da doação';

  @override
  String get donationFocusSubtitle =>
      'Opcional. Ajuda a priorizar no que trabalhar a seguir.';

  @override
  String get donationGeneralSupportTitle => 'Apoio geral';

  @override
  String get donationGeneralSupportSubtitle => 'A melhor opção geral';

  @override
  String get donationSupportDevelopmentTitle => 'Apoiar o desenvolvimento';

  @override
  String get donationSupportDevelopmentSubtitle =>
      'Doação opcional para financiar manutenção e funcionalidades';

  @override
  String get donationOptionsTitle => 'Opções de doação';

  @override
  String get donationOptionsSubtitle =>
      'A sua contribuição mantém esta ferramenta gratuita, cuidada e orientada pela comunidade';

  @override
  String get donationRecommendedBadge => 'Recomendado';

  @override
  String get donationLiberapayFlexibleSupport => 'Opções flexíveis de apoio';

  @override
  String get donationTraditionalPayments =>
      'Métodos de pagamento tradicionais (cartão, PayPal, banco)';

  @override
  String get donationRecurringOrOneTime =>
      'Apoio recorrente flexível ou contribuição única';

  @override
  String get donationTrustedByOpenSource =>
      'De confiança para programadores open source';

  @override
  String get donationOpeningBrowser => 'A abrir o navegador...';

  @override
  String get donationViaLiberapay => 'Doar via Liberapay';

  @override
  String get donationLiberapayNote =>
      'O Liberapay é uma plataforma de doações sem fins lucrativos em que projetos open source confiam.';

  @override
  String get donationCryptoSupportTitle => 'Apoio direto com criptomoedas';

  @override
  String get donationCryptoSupportSubtitle =>
      'Opção focada na privacidade • Leia o QR ou copie o endereço';

  @override
  String get donationBtcShort => 'BTC';

  @override
  String get donationEthShort => 'ETH';

  @override
  String get donationGeneralShort => 'Geral';

  @override
  String get donationBitcoinNetworkOnly => 'Apenas rede Bitcoin';

  @override
  String get donationEthereumNetworkOnly => 'Apenas mainnet Ethereum';

  @override
  String get donationBitcoinTitle => 'Doação em Bitcoin';

  @override
  String get donationEthereumTitle => 'Doação em Ethereum';

  @override
  String get donationQrUnavailable => 'Código QR indisponível';

  @override
  String get donationAddressTitle => 'Endereço';

  @override
  String get donationBtcAddressCopied => 'Endereço BTC copiado';

  @override
  String get donationEthAddressCopied => 'Endereço ETH copiado';

  @override
  String get donationShareTextCopied => 'Texto de partilha copiado';

  @override
  String get donationCopyAddress => 'Copiar endereço';

  @override
  String get donationShareAction => 'Partilhar';

  @override
  String get donationSentAction => 'Já enviei uma doação';

  @override
  String get donationSecurityNote =>
      'Nota de segurança: nunca confie em endereços de doação vistos em capturas de ecrã, avaliações ou páginas de terceiros. Use apenas este ecrã integrado na aplicação.';

  @override
  String deviceInterfaceTitle(Object id, Object classInfo) {
    return 'Interface $id • $classInfo';
  }

  @override
  String get deviceAltSettingLabel => 'Definição alt';

  @override
  String get deviceClassLabel => 'Classe';

  @override
  String deviceEndpointsTitle(int count) {
    return 'Endpoints ($count)';
  }

  @override
  String get deviceNoEndpoints => 'Sem endpoints';

  @override
  String deviceEndpointAddressSummary(
    Object address,
    Object number,
    Object attributes,
  ) {
    return 'End. $address • EP n.º $number • Atr. $attributes';
  }

  @override
  String deviceEndpointMaxPacket(Object value) {
    return 'MaxPkt $value';
  }

  @override
  String deviceEndpointInterval(Object value) {
    return 'Intervalo $value';
  }

  @override
  String get deviceControlTransferDefaultTitle => 'Transferência de controlo';

  @override
  String get deviceRequestedLengthLabel => 'Comprimento pedido';

  @override
  String get deviceActualLengthLabel => 'Comprimento real';

  @override
  String get deviceResultLabel => 'Resultado';

  @override
  String get deviceTransferSuccess => 'Sucesso';

  @override
  String get deviceTransferFailed => 'Falhou';

  @override
  String get deviceResponseBytesHexTitle => 'Bytes de resposta (hex)';

  @override
  String get deviceParsedFieldsTitle => 'Campos analisados';

  @override
  String get deviceNoParsedFieldsAvailable =>
      'Não há campos analisados disponíveis.';

  @override
  String get deviceRawBytesTitle => 'Bytes brutos';

  @override
  String deviceInterfaceReportTitle(
    Object interfaceNumber,
    Object reportLength,
  ) {
    return 'Interface $interfaceNumber • Relatório de $reportLength bytes';
  }

  @override
  String get deviceParsedSummaryTitle => 'Resumo analisado';

  @override
  String get deviceNoParsedHidSummaryAvailable =>
      'Não há resumo HID analisado disponível.';

  @override
  String get deviceReportHexTitle => 'Hex do relatório';

  @override
  String get historyEntryNotFoundTitle => 'Entrada não encontrada';

  @override
  String get historyEntryNotFoundBody =>
      'Este item do histórico já não existe.';

  @override
  String get historyUnableToOpenDetail =>
      'Não foi possível abrir o detalhe do histórico.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'IR Blaster';

  @override
  String get loading => 'Carregando…';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get failedToStart => 'Falha ao iniciar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get quickTilePower => 'Ligar';

  @override
  String get quickTileMute => 'Mudo';

  @override
  String get quickTileVolumeUp => 'Vol +';

  @override
  String get quickTileVolumeDown => 'Vol -';

  @override
  String get homeUsbPermissionRequiredMessage =>
      'Este telefone não tem IR integrado. Foi detectado um dongle IR USB, mas ainda não tem permissão.\n\naceite o aviso USB para ativar o envio de IR.';

  @override
  String get homeUsbPermissionDeniedMessage =>
      'Este telefone não tem IR integrado. Foi detectado um dongle IR USB, mas a permissão USB foi negada.\n\npeça-a novamente e aceite o aviso para ativar o IR.';

  @override
  String get homeUsbPermissionGrantedMessage =>
      'Este telefone não tem IR integrado. O dongle IR USB está autorizado, mas ainda não foi inicializado.';

  @override
  String get homeUsbOpenFailedMessage =>
      'Este telefone não tem IR integrado. O dongle IR USB foi detectado e autorizado, mas não pôde ser iniciado.\n\nreconecte-o e tente novamente.';

  @override
  String get homeUsbReadyMessage => 'Este telefone não tem IR integrado.';

  @override
  String get homeUsbNoDeviceMessage =>
      'Este telefone não tem IR integrado e não há nenhum dongle IR USB compatível conectado.\n\nAinda pode criar, importar e gerenciar controles, mas para emitir IR é preciso usar um dongle USB compatível ou um adaptador de áudio para IR.';

  @override
  String get homeUsbOptionPlugIn =>
      'conecte um dongle IR USB compatível e aceite a permissão.';

  @override
  String get homeUsbOptionReady => 'Pronto para usar.';

  @override
  String get homeUsbOptionPermissionRequired =>
      'Conectado. Permissão necessária.';

  @override
  String get homeUsbOptionPermissionDenied =>
      'Permissão negada. peça novamente.';

  @override
  String get homeUsbOptionPermissionGranted =>
      'Autorizado. A iniciar o dongle.';

  @override
  String get homeUsbOptionOpenFailed =>
      'Autorizado, mas a inicialização falhou.';

  @override
  String get homeHardwareBannerNoInternal =>
      'Este telefone não tem IR integrado. Conecte um dongle IR USB ou ative o modo áudio em Configurações.';

  @override
  String get homeHardwareBannerPermissionRequired =>
      'Dongle USB detectado. É necessária permissão para enviar IR.';

  @override
  String get homeHardwareBannerPermissionDenied =>
      'A permissão USB foi negada. peça novamente para enviar IR.';

  @override
  String get homeHardwareBannerPermissionGranted =>
      'Dongle USB autorizado. aguardando inicialização.';

  @override
  String get homeHardwareBannerOpenFailed =>
      'Dongle USB autorizado, mas a inicialização falhou.';

  @override
  String get homeHardwareBannerReady => 'USB está listo.';

  @override
  String get homeHardwareRequiredTitle =>
      'É necessário hardware IR para enviar controles';

  @override
  String get homeUsbDongleRecommended => 'Dongle IR USB (recomendado)';

  @override
  String get homeAudioAdapterAlternative =>
      'Adaptador IR por áudio (alternativa)';

  @override
  String get homeAudioAdapterDescription =>
      'Configurações → Emissor IR → Áudio (1 LED / 2 LED). Requer um adaptador de áudio para IR.';

  @override
  String get close => 'Fechar';

  @override
  String get homeChooseTransmitter => 'Escolha um transmissor';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get homeUsbPermissionSentApprove =>
      'Pedido de permissão USB enviado. aceite o aviso para ativar o USB.';

  @override
  String get homeUsbDongleNotDetected =>
      'Nenhum dongle IR USB compatível foi detectado. conecte-o e tente novamente.';

  @override
  String get homeUsbPermissionRequestFailed =>
      'Não foi possível pedir a permissão USB.';

  @override
  String get working => 'Processando…';

  @override
  String get requestUsbPermission => 'Pedir permissão USB';

  @override
  String get homeHardwareTip =>
      'Dica: ainda pode criar e ordenar controles. O hardware só é necessário ao transmitir.';

  @override
  String get homeNoIrTransmitterTitle => 'Nenhum emissor IR disponível';

  @override
  String get homeHardwareRequiredBody =>
      'O IR Blaster pode criar e gerenciar controles remotos em qualquer telefone. Para realmente enviar comandos por infravermelho, seu dispositivo precisa de uma das opções de hardware abaixo.';

  @override
  String get homeCanStillUseWithoutHardware =>
      'Você ainda pode criar, importar e organizar controles remotos agora mesmo.';

  @override
  String get homeWaysToUseIrBlaster => 'Formas de usar o IR Blaster';

  @override
  String get homeBuiltInIrOptionTitle => 'Telefone com IR embutido';

  @override
  String get homeBuiltInIrOptionSubtitle =>
      'Funciona em telefones compatíveis com emissor IR embutido. Este telefone não tem um.';

  @override
  String get homeBuiltInIrUnavailable => 'Não disponível neste telefone';

  @override
  String get homeUsbFamilyTiqiaaZaza => 'Tiqiaa / ZaZa';

  @override
  String get homeUsbFamilyElkSmart => 'ElkSmart';

  @override
  String get homeAudioAccessoryLabel => 'Adaptador de áudio de 3,5 mm';

  @override
  String get homeContinueWithoutHardware => 'Continuar sem hardware';

  @override
  String get homeHowItWorks => 'Como funciona';

  @override
  String get settingsNavLabel => 'configurações';

  @override
  String get dismiss => 'Descartar';

  @override
  String get remotesNavLabel => 'controles';

  @override
  String get macrosNavLabel => 'Macros';

  @override
  String get signalTesterNavLabel => 'Probador IR';

  @override
  String get settingsTitle => 'configurações';

  @override
  String get remoteNoIrEmitterTitle => 'Sem emissor IR';

  @override
  String get remoteNoIrEmitterMessage => 'Este dispositivo não tem emissor IR';

  @override
  String get remoteNoIrEmitterNeedsEmitter =>
      'Este app precisa de um emissor IR para funcionar';

  @override
  String get remoteDismiss => 'Descartar';

  @override
  String get remoteClose => 'Fechar';

  @override
  String remoteFailedToSend(Object error) {
    return 'Falha ao enviar IR: $error';
  }

  @override
  String remoteFailedToStartLoop(Object error) {
    return 'Não foi possível iniciar o ciclo: $error';
  }

  @override
  String remoteLoopStoppedFailed(Object error) {
    return 'Ciclo parado, envio falhado: $error';
  }

  @override
  String remoteLoopingHint(Object title) {
    return 'Repetindo \"$title\". Toque em Parar acima para parar.';
  }

  @override
  String get remoteLoopStopped => 'Ciclo detenido.';

  @override
  String get remoteUpdatedNotFound =>
      'O controle foi atualizado na tela. Não foi encontrado na lista salva.';

  @override
  String remoteUpdatedNamed(Object name) {
    return 'Foi atualizado \"$name\".';
  }

  @override
  String remoteDeleteFailed(Object error) {
    return 'Falha ao excluir: $error';
  }

  @override
  String get remoteNotFoundSavedList =>
      'Não foi encontrado o controle na lista salva.';

  @override
  String remoteDeletedNamed(Object name) {
    return 'Foi excluído \"$name\".';
  }

  @override
  String get buttonFallbackTitle => 'Botão';

  @override
  String get imageFallbackTitle => 'Imagem';

  @override
  String get noBrowserAvailable => 'Nenhum navegador disponível';

  @override
  String failedToOpen(Object error) {
    return 'Não foi possível abrir: $error';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get settingsRestoreDemoTitle => 'Restaurar controles de demonstração?';

  @override
  String get settingsRestoreDemoMessage =>
      'Isto vai substituir os seus controles atuais pelos controles de demonstração integrados. É recomendado exportar uma cópia se quiser manter a lista atual.';

  @override
  String get settingsRestoreDemoConfirm => 'Restaurar demo';

  @override
  String get settingsDemoRemotesRestored =>
      'Controles de demonstração restaurados.';

  @override
  String get settingsDeleteAllRemotesTitle => 'Excluir todos os controles?';

  @override
  String get settingsDeleteAllRemotesMessage =>
      'Isto remove todos os controles deste dispositivo. Esta ação não pode ser desfeita.';

  @override
  String get settingsDeleteAllConfirm => 'Excluir tudo';

  @override
  String get settingsAllRemotesDeleted => 'Todos os controles foram excluídos.';

  @override
  String get themeAuto => 'Tema auto';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeDescAuto => 'Segue as configurações do dispositivo';

  @override
  String get themeDescLight => 'Sempre claro e nítido';

  @override
  String get themeDescDark => 'Descansa a vista';

  @override
  String get themeHintAuto =>
      'O tema muda apenas quando você alterna entre modo claro e escuro no dispositivo';

  @override
  String get themeHintLight =>
      'Perfeito para usar de dia e em locais bem iluminados';

  @override
  String get themeHintDark =>
      'Reduz a fadiga visual com pouca luz e economiza bateria em telas OLED';

  @override
  String get supportDevelopmentTitle => 'Apoyar desarrollo';

  @override
  String get supportDevelopmentSubtitle =>
      'Ajuda a manter o IR Blaster e a compatibilidade de hardware';

  @override
  String get supportDevelopmentBody =>
      'Sem anúncios, sem rastreamento nem funções bloqueadas. O seu apoio financia protocolos, suporte USB e melhor compatibilidade entre dispositivos.';

  @override
  String get donate => 'Donar';

  @override
  String get starRepo => 'Dar estrella';

  @override
  String get repositoryLinkCopied => 'Enlace do repositorio copiado';

  @override
  String get supportPillLocalOnly => 'Apenas local';

  @override
  String get supportPillNoTracking => 'Sem rastreio';

  @override
  String get supportPillHardwareAware => 'Consciente do hardware';

  @override
  String get supportPillOpenSource => 'Código aberto';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get appearanceSubtitle => 'Personalize a experiência visual';

  @override
  String get localizationTitle => 'Idioma';

  @override
  String get localizationSubtitle =>
      'Idioma do app e comportamento da tradução';

  @override
  String localizationAutoUsing(Object language) {
    return 'Auto: usando $language';
  }

  @override
  String get localizationAutoDescription =>
      'O app segue o idioma do dispositivo quando possível.';

  @override
  String get localizationManualDescription =>
      'O idioma do app foi definido manualmente.';

  @override
  String get useSystemLanguageTitle => 'Usar idioma do sistema';

  @override
  String useSystemLanguageEnabled(Object language) {
    return 'Seguindo o idioma do dispositivo: $language';
  }

  @override
  String get useSystemLanguageDisabled =>
      'Usa o idioma escolhido abaixo em vez do padrão do dispositivo.';

  @override
  String get chooseAppLanguage => 'Escolher idioma do app';

  @override
  String get languagePickerDisabledHint =>
      'Desative o idioma do sistema para escolher um manualmente.';

  @override
  String get searchLanguages => 'pesquisar idiomas';

  @override
  String get noLanguagesFound => 'Nenhum idioma correspondente';

  @override
  String get localizationHint =>
      'Se o idioma do sistema estiver ativo, o app segue a configuração regional do dispositivo e usa inglês se faltar uma tradução. Desative-o para fixar um idioma.';

  @override
  String get appLanguageTitle => 'Idioma do app';

  @override
  String get appLanguageHint =>
      'Auto segue o idioma do dispositivo. Escolha aqui inglês ou francês para forçar apenas no app.';

  @override
  String get languageAuto => 'Auto (sistema)';

  @override
  String get languageAutoDescription =>
      'Seguir o idioma do dispositivo automaticamente';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageEnglishDescription => 'Forçar o app a usar sempre inglês';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageFrenchDescription => 'Forçar o app a usar sempre francês';

  @override
  String get languageAutoShort => 'Auto';

  @override
  String get languageEnglishShort => 'Inglês';

  @override
  String get languageFrenchShort => 'Francês';

  @override
  String get useDynamicColors => 'Usar colores dinámicos';

  @override
  String get themeChoiceAuto => 'Auto';

  @override
  String get themeChoiceLight => 'Claro';

  @override
  String get themeChoiceDark => 'Escuro';

  @override
  String get irTransmitterTitle => 'Emissor IR';

  @override
  String get irTransmitterSubtitle => 'Escolha que hardware envia controles IR';

  @override
  String get learningModeEntryTitle => 'Modo de aprendizagem';

  @override
  String get learningModeEntrySubtitle =>
      'Capture um botão de um controle remoto físico passo a passo';

  @override
  String get learningModeTitle => 'Modo de aprendizagem';

  @override
  String get learningModeHeroTitle => 'Aprenda um botão remoto de forma limpa';

  @override
  String get learningModeHeroSubtitle =>
      'Configure seu receptor, prepare o controle remoto original, capture um comando e revise-o antes de salvá-lo em um controle remoto.';

  @override
  String get learningModeReadyBadge => 'Receptor pronto';

  @override
  String get learningModeNeedsPermissionBadge => 'Permissão USB necessária';

  @override
  String get learningModeSetupBadge => 'Configuração do receptor necessária';

  @override
  String get learningModeNoReceiverBadge => 'Nenhum receptor de aprendizagem';

  @override
  String get learningModeCheckingBadge => 'Verificando hardware';

  @override
  String get learningModeFourStepFlow => 'Fluxo guiado em 4 etapas';

  @override
  String get learningModeSaveAnywhereBadge => 'Revise antes de salvar';

  @override
  String get learningModeGuideTitle => 'Escolha onde a captura deve acontecer';

  @override
  String get learningModeStepHardwareShort => 'Hardware';

  @override
  String get learningModeStepPrepareShort => 'Preparar';

  @override
  String get learningModeStepCaptureShort => 'Capturar';

  @override
  String get learningModeStepReviewShort => 'Análise';

  @override
  String get learningModeStepHardwareTitle =>
      'Verifique o hardware do receptor';

  @override
  String get learningModeStepHardwareSubtitle =>
      'Certifique-se de que um receptor de aprendizagem compatível esteja conectado e autorizado antes de começar.';

  @override
  String get learningModeCurrentSenderLabel => 'Transmissor atual';

  @override
  String get learningModeReceiverStatusLabel => 'Status de aprendizagem';

  @override
  String get learningModeCheckingHardwareBody =>
      'Verificando o estado do transmissor disponível e do receptor USB.';

  @override
  String get learningModeHardwareReadyBody =>
      'Um dongle USB IR é conectado e inicializado. Este é o lugar certo para iniciar o fluxo de aprendizagem assim que a fiação de captura estiver conectada.';

  @override
  String get learningModeHardwarePermissionBody =>
      'Um dongle USB está presente, mas a permissão do Android ainda o bloqueia. Conceda permissão USB na seção do transmissor antes de aprender.';

  @override
  String get learningModeHardwareSetupBody =>
      'Um dongle foi parcialmente detectado, mas ainda precisa ser configurado ou reconectado antes que o aprendizado possa começar de forma confiável.';

  @override
  String get learningModeHardwareNoReceiverBody =>
      'Nenhum hardware receptor compatível está disponível atualmente. O modo de aprendizagem destina-se a dongles externos suportados com capacidade de recepção.';

  @override
  String get learningModeRefreshHardware => 'Atualizar status do hardware';

  @override
  String get learningModeHardwareTipTitle => 'Melhor colocação';

  @override
  String get learningModeHardwareTipBody =>
      'O Modo de Aprendizagem reside no Transmissor IR porque depende da disponibilidade do hardware e é usado com menos frequência do que o envio de controles remotos.';

  @override
  String get learningModeStepPrepareTitle =>
      'Prepare o controle remoto original';

  @override
  String get learningModeStepPrepareSubtitle =>
      'Decida o que você está aprendendo e mantenha o controle remoto original estável e próximo ao receptor.';

  @override
  String get learningModeButtonNameLabel => 'Nome do botão';

  @override
  String get learningModeButtonNameHint =>
      'Por exemplo: HDMI 1, Alimentação, Menu';

  @override
  String get learningModeSinglePress => 'Pressão única';

  @override
  String get learningModeHoldButton => 'Botão segurar';

  @override
  String get learningModePreparationChecklistTitle => 'Antes de capturar';

  @override
  String get learningModePreparationItemDistance =>
      'Mantenha o controle remoto original a cerca de 2 a 5 cm do receptor.';

  @override
  String get learningModePreparationItemOneButton =>
      'Aprenda um botão de cada vez e use primeiro um toque curto e limpo.';

  @override
  String get learningModePreparationItemStill =>
      'Mantenha ambos os dispositivos estáveis ​​para evitar capturas ruidosas ou parciais.';

  @override
  String get learningModeStepCaptureTitle => 'Capture o sinal';

  @override
  String get learningModeStepCaptureSubtitle =>
      'Ouça um único comando e bloqueie o resultado antes de revisá-lo.';

  @override
  String get learningModeCaptureReadyTitle => 'Pronto para ouvir';

  @override
  String get learningModeCaptureReadyBody =>
      'O estado do seu hardware parece bom. O back-end de captura será conectado a esta etapa a seguir.';

  @override
  String get learningModeCaptureBlockedTitle =>
      'Hardware ainda não está pronto';

  @override
  String get learningModeCaptureBlockedBody =>
      'Você ainda pode revisar o fluxo agora, mas a captura deverá aguardar até que o receptor esteja pronto.';

  @override
  String get learningModeStartListening => 'Comece a ouvir';

  @override
  String get learningModeCaptureStubTitle =>
      'O back-end de captura vem a seguir';

  @override
  String get learningModeCaptureStubBody =>
      'Essa tela é totalmente estruturada primeiro para que o fluxo de captura final possa ser conectado aos estados reais do hardware, em vez de ser anexado posteriormente.';

  @override
  String get learningModeCaptureStubMessage =>
      'A captura de aprendizagem ainda não está conectada. Esta tela estrutura o fluxo completo primeiro.';

  @override
  String get learningModeUnnamedCapture => 'Captura sem nome';

  @override
  String get learningModeStatusCheckingTitle => 'Verificando o receptor';

  @override
  String get learningModeStatusNoReceiverTitle => 'Receptor não está pronto';

  @override
  String get learningModeStatusPermissionTitle => 'Permissão USB necessária';

  @override
  String get learningModeStatusSetupTitle =>
      'O receptor precisa de configuração';

  @override
  String get learningModeStatusReadyTitle => 'Pronto para aprender';

  @override
  String get learningModeStatusListeningTitle => 'Ouvindo um sinal';

  @override
  String get learningModeStatusCapturedTitle => 'Sinal capturado';

  @override
  String get learningModeStatusReadyBody =>
      'Dê um nome ao botão, aponte o controle remoto original para o receptor e comece a ouvir quando estiver pronto.';

  @override
  String get learningModeStatusListeningBody =>
      'Pressione o botão do controle remoto original agora. Depois que a captura for conectada, esse estado será bloqueado no próximo sinal limpo.';

  @override
  String learningModeStatusCapturedBody(Object buttonName) {
    return 'Uma visualização do sinal aprendido está pronta para $buttonName. Reproduza-o, confirme se funciona e salve-o em sua biblioteca.';
  }

  @override
  String get learningModeConnectReceiverTitle =>
      'Conecte um dongle de aprendizagem compatível';

  @override
  String get learningModeConnectReceiverBody =>
      'O modo de aprendizagem depende do hardware externo que pode receber IR. Depois que o receptor for detectado e autorizado, esta página se tornará um fluxo direto de escuta, teste e salvamento.';

  @override
  String get learningModeListenCardTitle => 'Ouça um botão';

  @override
  String get learningModeListenCardBody =>
      'Defina primeiro um rótulo, se desejar, depois comece a ouvir e pressione o botão no controle remoto original.';

  @override
  String get learningModeReadyToListenTitle => 'Pronto para ouvir';

  @override
  String get learningModeReadyToListenBody =>
      'Esta é a principal superfície de captura. Comece a ouvir apenas quando o controle remoto original estiver apontado e estável.';

  @override
  String get learningModeListeningNowTitle => 'Ouvindo agora';

  @override
  String get learningModeListeningNowBody =>
      'Pressione o botão do controle remoto original uma vez. Use a captura de visualização para percorrer o resto do andaime antes que o back-end de captura real seja conectado.';

  @override
  String get learningModePreviewCaptureAction => 'Visualizar sinal capturado';

  @override
  String get learningModeCapturedSummary => 'Visualização do sinal aprendido';

  @override
  String get learningModeResultActionsTitle => 'Teste e salve';

  @override
  String get learningModeResultActionsBody =>
      'Reproduza o sinal aprendido, verifique se o dispositivo alvo responde e salve-o como um botão reutilizável.';

  @override
  String get learningModeReplayAction => 'Repetir';

  @override
  String get learningModeReplayStubMessage =>
      'O replay ainda não está conectado. Esta é a estrutura da UI para o fluxo final de aprendizado, teste e salvamento.';

  @override
  String get learningModeSaveStubMessage =>
      'Salvar ainda não está conectado. A próxima etapa é conectar esta tela ao botão Criar e aos controles remotos existentes.';

  @override
  String get learningModeLearnAnotherAction => 'Aprenda outro botão';

  @override
  String get learningModeStepReviewTitle => 'Revise e salve';

  @override
  String get learningModeStepReviewSubtitle =>
      'Confirme o que foi aprendido e escolha onde ele deve ficar na sua biblioteca remota.';

  @override
  String get learningModeSaveToExistingRemote => 'Remoto existente';

  @override
  String get learningModeCreateNewRemote => 'Novo controle remoto';

  @override
  String get learningModeProtocolPreviewTitle => 'Visualização do protocolo';

  @override
  String get learningModeProtocolPreviewBody =>
      'Os detalhes do protocolo decodificado aparecerão aqui assim que o receptor capturar um pressionamento de botão limpo.';

  @override
  String get learningModeRawPreviewTitle => 'Reserva bruta';

  @override
  String get learningModeRawPreviewBody =>
      'Se a decodificação estiver incompleta, a captura de tempo bruto ainda estará disponível aqui para revisão e salvamento.';

  @override
  String get learningModeSaveCapture => 'Salvar captura';

  @override
  String get learningModeReviewTipTitle => 'Para onde isso irá a seguir';

  @override
  String get learningModeReviewTipBody =>
      'A próxima etapa de implementação deve conectar este painel de revisão ao botão Criar e aos controles remotos existentes para que o sinal aprendido caia diretamente em sua biblioteca.';

  @override
  String get learningModeFinishPreview => 'Concluir visualização';

  @override
  String get backAction => 'Back';

  @override
  String get interactionTitle => 'Interacción';

  @override
  String get interactionSubtitle => 'Resposta tátil e layout do controle';

  @override
  String get hapticFeedbackTitle => 'Respuesta háptica';

  @override
  String get hapticFeedbackSubtitle => 'Vibrar ao tocar e ao executar ações';

  @override
  String get forceInAppVibrationTitle => 'Forçar vibração no app';

  @override
  String get forceInAppVibrationSubtitle =>
      'Usar o vibrador diretamente mesmo que o feedback tátil do sistema esteja desligado';

  @override
  String get forceInAppVibrationWarning =>
      'Opção avançada. O app pode vibrar mesmo quando o feedback tátil do Android estiver desativado globalmente.';

  @override
  String get forceInAppVibrationBlockedMasterWarning =>
      'Android system vibration is disabled. Force in-app vibration cannot override it on this device.';

  @override
  String get forceInAppVibrationNoVibratorWarning =>
      'This device reports no vibrator hardware, so in-app vibration cannot work.';

  @override
  String get intensity => 'Intensidad';

  @override
  String get intensityLight => 'Claro';

  @override
  String get intensityMedium => 'Media';

  @override
  String get intensityStrong => 'Fuerte';

  @override
  String get flipRemoteDefaultTitle => 'Inverter vista do controle por defecto';

  @override
  String get flipRemoteDefaultSubtitle =>
      'Abre as telas do controle giradas em 180° (para dongles USB montados embaixo).';

  @override
  String get remoteViewFlipped =>
      'A visualização do controle vai abrir invertida.';

  @override
  String get remoteViewNormal => 'A visualização do controle vai abrir normal.';

  @override
  String get backupTitle => 'Cópia';

  @override
  String get backupSubtitle => 'Importar/exportar controles e macros';

  @override
  String get importBackup => 'Importar cópia';

  @override
  String get importBackupSubtitle =>
      'Importa cópias de controles/macros ou arquivos do Flipper Zero, LIRC ou IRPLUS';

  @override
  String get bulkImportFolder => 'Importar pasta';

  @override
  String get bulkImportFolderSubtitle =>
      'Importar vários controles de uma pasta';

  @override
  String get exportBackup => 'Exportar cópia';

  @override
  String get exportBackupSubtitle =>
      'Salvar controles + macros como un JSON en Descargas';

  @override
  String get restoreDemoRemotes => 'Restaurar controles de demonstração';

  @override
  String get restoreDemoRemotesSubtitle =>
      'Substituir os controles atuais pela demonstração integrada';

  @override
  String get deleteAllRemotes => 'Excluir todos os controles';

  @override
  String get deleteAllRemotesSubtitle =>
      'Excluir todos os controles deste dispositivo';

  @override
  String get backupTip =>
      'Dica: exporte uma cópia antes de grandes alterações. A importação aceita cópias completas, cópias JSON antigas de controles e arquivos .ir do Flipper Zero.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutSubtitle => 'Informações do app e detalhes de código aberto';

  @override
  String aboutAppNameWithCreator(Object creator) {
    return 'IR Blaster - $creator';
  }

  @override
  String versionLabel(Object version) {
    return 'Versión $version';
  }

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get viewOnGitHub => 'Ver en GitHub';

  @override
  String get repositoryUrlCopied => 'URL do repositorio copiada';

  @override
  String get reportIssue => 'Reportar problema';

  @override
  String get reportIssueSubtitle => 'Erros e pedidos de recursos';

  @override
  String get issuesUrlCopied => 'URL de issues copiada';

  @override
  String get license => 'Licencia';

  @override
  String get openSourceLicense => 'Licencia de código aberto';

  @override
  String get licenseUrlCopied => 'URL da licença copiada';

  @override
  String get companyName => 'KaijinLab Inc.';

  @override
  String get visitWebsite => 'Visitar nuestro sitio web';

  @override
  String get companyUrlCopied => 'URL da empresa copiada';

  @override
  String get licenses => 'Licencias';

  @override
  String get openSourceLicenses => 'Licencias de código aberto';

  @override
  String byCreator(Object creator) {
    return 'por $creator';
  }

  @override
  String get deviceControlsTitle => 'controles do dispositivo';

  @override
  String get deviceControlsSubtitle =>
      'Mostrar botões favoritos na página de controles do sistema';

  @override
  String get manageFavorites => 'Gerir favoritos';

  @override
  String get manageFavoritesSubtitle =>
      'Escolha quais botões aparecem nos controles do dispositivo';

  @override
  String get quickSettingsTitle => 'Configurações rápidas';

  @override
  String get quickSettingsSubtitle =>
      'Adicionar blocos para atalhos de energia e volume';

  @override
  String get configureTiles => 'Configurar blocos';

  @override
  String get configureTilesSubtitle => 'Atribuir blocos aos botões do controle';

  @override
  String get tvKillTitle => 'TVKill';

  @override
  String get tvKillSubtitle =>
      'Ciclo universal de energia para dispositivos seus';

  @override
  String get openTvKill => 'Abrir TVKill';

  @override
  String get openTvKillSubtitle =>
      'Ciclar códigos de energia (use apenas em dispositivos seus)';

  @override
  String get failedToLoadTransmitterSettings =>
      'Falha ao carregar as configurações do emissor.';

  @override
  String get usbStatusReady =>
      'O dongle USB está conectado e pronto para enviar IR.';

  @override
  String get usbStatusPermissionRequired =>
      'Dongle USB detectado. Peça permissão USB e aceite o aviso do sistema.';

  @override
  String get usbStatusPermissionDenied =>
      'A permissão USB foi negada para o dongle conectado. Peça novamente e aceite o aviso.';

  @override
  String get usbStatusPermissionGranted =>
      'A permissão USB foi concedida. O dongle ainda precisa ser inicializado antes de poder enviar IR.';

  @override
  String get usbStatusOpenFailed =>
      'A permissão USB foi concedida, mas o dongle não pôde ser inicializado. Reconecte-o e tente novamente.';

  @override
  String get usbStatusNoDevice =>
      'Não foi detectado un dongle IR USB compatível.';

  @override
  String get usbSelectPermissionRequired =>
      'Dongle USB detectado, mas não autorizado. Toque em \"Pedir permissão USB\".';

  @override
  String get usbSelectPermissionDenied =>
      'A permissão USB foi negada. Toque em \"Pedir permissão USB\" e aceite o aviso.';

  @override
  String get usbSelectPermissionGranted =>
      'A permissão USB foi concedida, mas o dongle ainda não foi inicializado. Tente reconectá-lo.';

  @override
  String get usbSelectOpenFailed =>
      'A permissão USB foi concedida, mas o dongle não pôde ser inicializado. Reconecte-o e tente novamente.';

  @override
  String get usbSelectNoDevice =>
      'Nenhum dongle IR USB compatível foi detectado. Conecte-o e depois toque em \"Pedir permissão USB\".';

  @override
  String get usbSelectReady => 'O dongle USB está pronto.';

  @override
  String get autoSwitchEnabledMessage =>
      'Troca automática ativada: usa USB quando está conectado, caso contrário Interno.';

  @override
  String get autoSwitchDisabledMessage =>
      'Cambio automático desativedo: a seleção do emissor ahora es manual.';

  @override
  String get failedToUpdateAutoSwitch =>
      'Falha ao atualizar a configuração de troca automática.';

  @override
  String get failedToSwitchTransmitter => 'Falha ao trocar o emissor.';

  @override
  String get deviceHasNoInternalIr =>
      'Este dispositivo não tem emissor IR integrado.';

  @override
  String get audioModeEnabledMessage =>
      'Modo áudio ativado. Usa o volume multimedia ao máximo e un adaptador LED de áudio a IR.';

  @override
  String get usbPermissionRequestSent => 'Solicitud de permissão USB enviada.';

  @override
  String get usbPermissionRequestSentApprove =>
      'Pedido de permissão USB enviado. aceite o aviso para ativar o USB.';

  @override
  String get usbAlreadyReady => 'O dongle USB já está inicializado e pronto.';

  @override
  String get failedToRequestUsbPermission =>
      'Não foi possível pedir a permissão USB.';

  @override
  String get transmitterHelpInternal =>
      'Usa o emissor IR integrado do telefone para enviar controles.';

  @override
  String get transmitterHelpUsb =>
      'Usa un dongle IR USB (requiere permissão) para enviar controles.';

  @override
  String get transmitterHelpAudio1 =>
      'Usa a saída de áudio (mono). Requiere un adaptador LED de áudio a IR e volume multimedia alto.';

  @override
  String get transmitterHelpAudio2 =>
      'Usa a saída de áudio (estéreo). Usa dos canales para un melhor control LED con adaptadores compatíveis.';

  @override
  String get transmitterInternal => 'IR interno';

  @override
  String get transmitterUsb => 'Dongle IR USB';

  @override
  String get transmitterAudio1 => 'áudio (1 LED)';

  @override
  String get transmitterAudio2 => 'áudio (2 LED)';

  @override
  String get failedToLoadTransmitterCapabilities =>
      'Falha ao carregar as capacidades do emissor.';

  @override
  String get selectedTransmitter => 'Emissor selecionado';

  @override
  String selectedTransmitterValue(Object effective, Object active) {
    return '$effective • Activo: $active';
  }

  @override
  String get refresh => 'Atualizar';

  @override
  String get autoSwitchTitle => 'Cambio auto';

  @override
  String get autoSwitchDisabledWhileAudio => 'Desativado ao usar modo áudio';

  @override
  String get autoSwitchUsesUsbOtherwiseInternal =>
      'Usa USB quando está conectado, caso contrário Interno';

  @override
  String get unavailableOnThisDevice => 'Não disponible en este dispositivo';

  @override
  String get openOnUsbAttachTitle => 'Abrir ao conectar USB';

  @override
  String get openOnUsbAttachSubtitle =>
      'O Android pode sugerir abrir o app quando um dongle IR USB compatível for conectado.';

  @override
  String get openOnUsbAttachEnabledMessage =>
      'Vai sugerir abrir o IR Blaster quando um dongle USB compatível for conectado.';

  @override
  String get openOnUsbAttachDisabledMessage =>
      'Não vai sugerir abrir ao conectar USB.';

  @override
  String get failedToUpdateSetting => 'Falha ao atualizar a configuração.';

  @override
  String get unnamedButton => 'Botão sem nome';

  @override
  String get iconFallback => 'Icono';

  @override
  String get remoteListReorderHint =>
      'Modo reordenar: mantenha pressionado e arraste uma cartão para moverla.';

  @override
  String get deleteRemoteTitle => 'Excluir controle?';

  @override
  String deleteRemoteMessage(Object name) {
    return '\"$name\" será removido permanentemente. Esta ação não pode ser desfeita.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get addToDeviceControlsTitle =>
      'Adicionar a controles do dispositivo?';

  @override
  String get addToDeviceControlsDescription =>
      'Acceso rápido en os controles do sistema.';

  @override
  String get skip => 'Omitir';

  @override
  String get add => 'Adicionar';

  @override
  String get addedToDeviceControls => 'Añadido a controles do dispositivo.';

  @override
  String deletedRemoteUndoUnavailable(Object name) {
    return '\"$name\" foi removido. Esta ação não pode ser desfeita.';
  }

  @override
  String remoteLayoutSummary(int count, Object layout) {
    return '$count botão(es) · $layout';
  }

  @override
  String get layoutComfort => 'Cómodo';

  @override
  String get layoutCompact => 'Compacto';

  @override
  String get open => 'Abrir';

  @override
  String get useThisRemote => 'Usar este controle';

  @override
  String get edit => 'Editar';

  @override
  String get editRemoteSubtitle => 'Renombrar e editar botões';

  @override
  String get thisCannotBeUndone => 'Isto não pode ser desfeito';

  @override
  String get searchRemotes => 'pesquisar controles';

  @override
  String get reorderRemotes => 'Reordenar controles';

  @override
  String get addRemote => 'Adicionar controle';

  @override
  String get more => 'Mais';

  @override
  String get reorderMode => 'Modo reordenar';

  @override
  String remoteButtonCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count buttons',
      one: '$count button',
    );
    return '$_temp0';
  }

  @override
  String get noRemotesYet => 'Ainda não há controles';

  @override
  String get noRemotesDescription =>
      'Crea un controle para empezar a enviar códigos IR.';

  @override
  String get noRemotesNextStep =>
      'Próximo passo: toque em Adicionar controle e depois adicione os seus primeiros botões.';

  @override
  String get actions => 'Acciones';

  @override
  String get macrosTitle => 'Macros';

  @override
  String get help => 'Ajuda';

  @override
  String get createMacro => 'Criar macro';

  @override
  String get timedMacrosTitle => 'Macros temporizadas';

  @override
  String get timedMacrosSubtitle =>
      'Automatiza secuencias de controles IR con temporización precisa';

  @override
  String get timedMacrosNextStep =>
      'Próximo passo: toque em Criar sua primeira macro, escolha um controle e depois adicione comandos e pausas.';

  @override
  String get macroFeatureToysTitle => 'Perfecto para brinquedos interactivos';

  @override
  String get macroFeatureToysDescription =>
      'Controla dispositivos como perros robô i-cybie, robôs i-sobot e otros brinquedos que precisan tiempo entre controles para procesar acciones.';

  @override
  String get macroFeatureTimingTitle => 'Control preciso do tiempo';

  @override
  String get macroFeatureTimingDescription =>
      'Adicione pausas entre controles (de 250 ms a duraciones personalizadas) para que o seu dispositivo responda antes de a seguinte acción.';

  @override
  String get macroFeatureManualTitle => 'Passos con continuación manual';

  @override
  String get macroFeatureManualDescription =>
      'Pausa a execução e espera o seu confirmación quando a animación varía o precisas confirmación visual.';

  @override
  String get exampleUseCase => 'Ejemplo de uso';

  @override
  String get macroExampleText =>
      'Modo avanzado de i-cybie:\n1. Enviar controle \"Mode\"\n2. Asalvar 1000 ms (el juguete procesa)\n3. Enviar \"Action 1\"\n4. Asalvar 1000 ms\n5. Enviar \"Action 2\"\n…y así sucesivamente de forma automática.';

  @override
  String get createFirstMacro => 'Crea o seu primeira macro';

  @override
  String get noRemote => 'Sem controle';

  @override
  String macroStepCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String get aboutTimedMacros => 'Sobre as macros temporizadas';

  @override
  String get aboutTimedMacrosDescription =>
      'As macros temporizadas permitem automatizar sequências de comandos IR com atrasos precisos entre cada passo.';

  @override
  String get sendCommand => 'Enviar controle';

  @override
  String get sendCommandDescription =>
      'Transmite un controle IR de o seu controle.';

  @override
  String get delay => 'Pausa';

  @override
  String get delayDescription =>
      'Espera uma duración indicada (p. ej. 1000 ms) antes do seguinte passo.';

  @override
  String get manualContinue => 'Continuación manual';

  @override
  String get manualContinueDescription =>
      'Pausa a execução hasta que toques Continuar (útil para animaciones de duración variable).';

  @override
  String get gotIt => 'Entendido';

  @override
  String get failedToSaveMacros => 'Falha ao salvar macros.';

  @override
  String deletedMacroNamed(Object name) {
    return 'Foi eliminado \"$name\".';
  }

  @override
  String get undo => 'desfazer';

  @override
  String get failedToRestoreMacro => 'Falha ao restaurar a macro.';

  @override
  String get deleteMacroTitle => 'Excluir macro?';

  @override
  String get deleteMacroMessage =>
      'Pode desfazer isto desde o próximo mensaje.';

  @override
  String get noRemotesAvailable => 'Não há controles disponibles.';

  @override
  String remoteButtonCountSummary(int count) {
    return '$count botão(es)';
  }

  @override
  String get remoteOrientationFlippedTooltip =>
      'Orientação: invertida (toque para normal)';

  @override
  String get remoteOrientationNormalTooltip =>
      'Orientação: normal (toque para inverter)';

  @override
  String get stopLoop => 'parar ciclo';

  @override
  String get reorderButtons => 'Reordenar botões';

  @override
  String get remoteReorderHint =>
      'Modo reordenar: mantenha pressionado e arraste un botão para moverlo.';

  @override
  String get manageRemote => 'Gerir controle';

  @override
  String get remoteNoButtons => 'Não há botões en este controle';

  @override
  String get remoteNoButtonsDescription =>
      'Usa \"Editar controle\" para adicionar o configurar botões.';

  @override
  String get editRemote => 'Editar controle';

  @override
  String get editRemoteActionsSubtitle =>
      'Renombrar, reordenar e editar botões';

  @override
  String remoteUpdatedNamedButton(Object name) {
    return 'Foi atualizado \"$name\".';
  }

  @override
  String buttonAddedNamed(Object name) {
    return 'Foi adicionado \"$name\".';
  }

  @override
  String get buttonDuplicated => 'Botão duplicado.';

  @override
  String get loopRunningForButton => 'O ciclo está ativo para este botão.';

  @override
  String get loopTip => 'Dica: usa Ciclo para repetir hasta detenerlo.';

  @override
  String get loopingBadge => 'Looping';

  @override
  String get codeCopied => 'Código copiado.';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get startLoop => 'Iniciar ciclo';

  @override
  String get editButtonSubtitle =>
      'Modificar etiqueta, código, protocolo e frecuencia';

  @override
  String get newButton => 'Novo botão';

  @override
  String get newButtonSubtitle => 'Criar um novo botão depois deste';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get duplicateButtonSubtitle => 'Criar uma cópia deste botão';

  @override
  String get removeFromDeviceControls => 'Remover de controles do dispositivo';

  @override
  String get addToDeviceControls => 'Adicionar a controles do dispositivo';

  @override
  String get deviceControlsButtonSubtitle =>
      'Muestra este botão en os controles do dispositivo do sistema';

  @override
  String get removedFromDeviceControls =>
      'Quitado de controles do dispositivo.';

  @override
  String get pinQuickTile => 'Fixar nos favoritos dos blocos rápidos';

  @override
  String get unpinQuickTile => 'Remover dos favoritos dos blocos rápidos';

  @override
  String get quickTileButtonSubtitle =>
      'Mostra este botão acima do seletor de blocos';

  @override
  String get removedFromQuickTileFavorites =>
      'Removido dos favoritos dos blocos rápidos.';

  @override
  String get pinnedToQuickTileFavorites =>
      'Fixado nos favoritos dos blocos rápidos.';

  @override
  String get duplicateAndEdit => 'Duplicar e editar';

  @override
  String get duplicateAndEditSubtitle =>
      'Criar uma cópia e editá-la imediatamente';

  @override
  String get done => 'Listo';

  @override
  String get run => 'Executar';

  @override
  String get untitledRemote => 'controle sem título';

  @override
  String get createRemoteTitle => 'Criar controle';

  @override
  String get editRemoteTitle => 'Editar controle';

  @override
  String get removeButtonTitle => 'Remover botão?';

  @override
  String get imageButtonRemovedMessage => 'Este botão de imagem será removido.';

  @override
  String namedButtonRemovedMessage(Object name) {
    return '\"$name\" será removido.';
  }

  @override
  String get remove => 'Remover';

  @override
  String importedButtonCount(int count) {
    return 'Foram importados $count botão(es).';
  }

  @override
  String importedButtonsFromExistingRemotes(int count) {
    return 'Foram importados $count botão(es) desde controles existentes.';
  }

  @override
  String get editButtonSettingsSubtitle =>
      'Cambiar etiqueta, sinal e configurações avanzados';

  @override
  String get createButtonCopySubtitle => 'Criar uma cópia deste botão';

  @override
  String get duplicateAndEditButtonSubtitle =>
      'Criar uma cópia e editá-la imediatamente';

  @override
  String get undoAvailableInNextSnackbar =>
      'Pode deshacerlo desde o próximo mensaje';

  @override
  String get buttonRemoved => 'Botão quitado.';

  @override
  String get remoteNameCannotBeEmpty =>
      'O nome do controle não pode estar vazio.';

  @override
  String get saveRemote => 'Salvar controle';

  @override
  String get remoteName => 'Nome do controle';

  @override
  String get remoteNameHint => 'p. ej., TV, aire acondicionado, tira LED';

  @override
  String get remoteNameHelper =>
      'Este nome aparece en o seu lista de controles.';

  @override
  String get layoutStyle => 'Estilo de diseño';

  @override
  String get layoutWideDescription =>
      'Ancho: botões de 2 columnas con detalhes extra (recomendado).';

  @override
  String get layoutCompactDescription =>
      'Compacto: grade clásica 4× (apenas iconos/texto).';

  @override
  String get importFromRemotes => 'Importar desde controles';

  @override
  String get importFromDatabase => 'Importar de BD';

  @override
  String get addButton => 'Adicionar botão';

  @override
  String get noButtonsYet => 'Ainda não há botões';

  @override
  String get createRemoteEmptyStateDescription =>
      'Adicione o seu primeiro botão e luego mantenha pressionado para editar o remover.';

  @override
  String get createButtonTitle => 'Criar botão';

  @override
  String get editButtonTitle => 'Editar botão';

  @override
  String failedToLoadProtocols(Object error) {
    return 'Falha ao carregar protocolos: $error';
  }

  @override
  String failedToLoadDatabaseKeys(Object error) {
    return 'Falha ao carregar chaves do banco de dados: $error';
  }

  @override
  String get presetPower => 'Enc.';

  @override
  String get presetVolume => 'Volume';

  @override
  String get presetChannel => 'Canal';

  @override
  String get presetNavigation => 'Navegación';

  @override
  String get all => 'Todos';

  @override
  String get completeRequiredFieldsToSave =>
      'Completa os campos obrigatórios para salvar';

  @override
  String get buttonLabelStepTitle => 'Etiqueta do botão';

  @override
  String get buttonLabelStepSubtitle =>
      'Escolha uma imagem, un icono o escreva uma etiqueta.';

  @override
  String get buttonColorStepTitle => 'Cor do botão';

  @override
  String get buttonColorStepSubtitle =>
      'Escolha un cor de fondo para este botão.';

  @override
  String get selectColor => 'Selecione cor:';

  @override
  String get noImageSelected => 'Não há imagem selecionada';

  @override
  String get gallery => 'Galería';

  @override
  String get builtIn => 'Integrado';

  @override
  String get removeImage => 'Remover imagem';

  @override
  String get requiredSelectImageOrSwitch =>
      'Obligatorio: selecione uma imagem, escolha un icono o cambia a Texto.';

  @override
  String get iconSelected => 'Icono selecionado';

  @override
  String get noIconSelected => 'Não há icono selecionado';

  @override
  String get chooseIcon => 'Escolher icono';

  @override
  String get removeIcon => 'Remover icono';

  @override
  String get requiredSelectIconOrSwitch =>
      'Obligatorio: selecione un icono o cambia a Imagem/Texto.';

  @override
  String get buttonText => 'Texto do botão';

  @override
  String get buttonTextHint => 'p. ej., Enc., Volume +, HDMI 1';

  @override
  String get buttonTextHelper => 'Este texto aparecerá en o botão.';

  @override
  String get requiredEnterButtonLabel => 'Obligatorio: introduza uma etiqueta.';

  @override
  String get defaultColorName => 'Predeterminado';

  @override
  String get newRemoteCreatedFromLastHit =>
      'Foi criado un controle novo con un botão do último acierto.';

  @override
  String get selectRemote => 'Selecionar controle';

  @override
  String remoteNumber(Object id) {
    return 'controle n.º $id';
  }

  @override
  String get newRemoteCreated => 'controle novo criado.';

  @override
  String get failedToCreateRemote => 'Falha ao criar o controle.';

  @override
  String get newRemoteEllipsis => 'Novo controle…';

  @override
  String addedToRemoteNamed(Object name) {
    return 'Añadido a $name.';
  }

  @override
  String get failedToAddToRemote => 'Falha ao adicionar ao controle.';

  @override
  String get newRemoteDefaultName => 'Novo controle';

  @override
  String jumpedToOffsetPaused(int offset) {
    return 'Saltó ao deslocação $offset. En pausa, pulsa retomar para seguir.';
  }

  @override
  String get sent => 'Enviado.';

  @override
  String failedToSend(Object error) {
    return 'Falha ao enviar: $error';
  }

  @override
  String get copiedProtocolCode => 'Copiado (protocolo:código).';

  @override
  String get savedToResults => 'Guardado en Resultados.';

  @override
  String invalidCodeForProtocol(Object error) {
    return 'Código inválido para o protocolo: $error';
  }

  @override
  String get copiedCurrentCandidate => 'Candidato atual copiado.';

  @override
  String get jumpToOffset => 'Saltar ao deslocação';

  @override
  String get jumpToBruteCursor => 'Saltar ao cursor de força bruta';

  @override
  String get jump => 'Saltar';

  @override
  String jumpedToCursorPaused(Object cursor) {
    return 'Saltó ao cursor 0x$cursor. En pausa, pulsa retomar para seguir.';
  }

  @override
  String get irSignalTester => 'Probador de sinal IR';

  @override
  String get stop => 'parar';

  @override
  String get selectButton => 'Selecionar botão';

  @override
  String get buttonNotFoundInRemotes => 'Botão não encontrado nos controles.';

  @override
  String sentNamed(Object name) {
    return 'Foi enviado \"$name\".';
  }

  @override
  String sendFailed(Object error) {
    return 'Falha no envio: $error';
  }

  @override
  String get noFavoritesYet => 'Ainda não há favoritos';

  @override
  String get deviceControlsEmptyHint =>
      'Mantenha pressionado un botão do controle e selecione \"Adicionar a controles do dispositivo\".';

  @override
  String get sendTest => 'Enviar teste';

  @override
  String get testSendCompleted => 'Teste de envio concluída.';

  @override
  String testSendFailed(Object error) {
    return 'Falha no envio de teste: $error';
  }

  @override
  String removedNamed(Object name) {
    return 'Foi removido \"$name\".';
  }

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get selectBrand => 'Selecionar marca';

  @override
  String get searchBrand => 'pesquisar marca…';

  @override
  String get selectModel => 'Selecionar modelo';

  @override
  String get searchModel => 'pesquisar modelo…';

  @override
  String get unnamedKey => 'Tecla sem nome';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get emDash => '-';

  @override
  String get searchCommands => 'pesquisar controles';

  @override
  String get noMatchingCommands => 'Não há controles correspondentes';

  @override
  String get quickTileFavoritesTitle => 'Favoritos dos blocos rápidos';

  @override
  String changeMappingForTile(Object tileLabel) {
    return 'Cambiar asignación do mosaico $tileLabel';
  }

  @override
  String get pickDifferentButton => 'Escolha un botão distinto';

  @override
  String get browseAllRemotesEllipsis => 'Explorar todos os controles…';

  @override
  String get invalidMacroFileFormat =>
      'Formato de arquivo de macro não válido.';

  @override
  String get failedToParseMacroFile =>
      'Não se pudo analizar o arquivo de macro.';

  @override
  String get deviceCodeLabel => 'Código de dispositivo';

  @override
  String get commandLabel => 'controle';

  @override
  String get editButtonCodeTitle => 'Editar código do botão';

  @override
  String get thisRemoteHasNoButtons => 'Este controle não tem botões.';

  @override
  String get selectCommand => 'Selecionar controle';

  @override
  String get databaseModeAutofillHint =>
      'El modo Base de dados completa o Passo 2 por ti (marca + modelo + protocolo). Tras importar uma tecla, pode ajustar tudo en Manual.';

  @override
  String get test => 'Probar';

  @override
  String get allSelectedButtonsWereDuplicates =>
      'Todos os botões elegidos eran duplicados.';

  @override
  String get noButtonsImported => 'Não se importó nenhum botão.';

  @override
  String importedButtonsSkippedDuplicates(int addedCount, int skippedCount) {
    return 'Foram importados $addedCount botão(es). Se omitieron $skippedCount duplicado(s).';
  }

  @override
  String get importAllMatchingTitle =>
      'Importar todos os botões correspondentes?';

  @override
  String get noMatchingKeysFound =>
      'Não se encontraron teclas correspondentes.';

  @override
  String importAllMatchingMessage(int count) {
    return 'Isto importará hasta $count teclas correspondentes de a seleção atual de a base de dados.';
  }

  @override
  String get importAll => 'Importar tudo';

  @override
  String get importingButtons => 'Importando botões…';

  @override
  String get allMatchingButtonsWereDuplicates =>
      'Todos os botões correspondentes eran duplicados.';

  @override
  String get quickPresets => 'configurações rápidos';

  @override
  String get selectDeviceFirst => 'Selecione primeiroo un dispositivo';

  @override
  String get searchByLabelOrHex => 'pesquisar por etiqueta o hex';

  @override
  String optionalRefinePresetKeys(Object preset) {
    return 'Opcional: afina as teclas predefinidas de $preset';
  }

  @override
  String get selectBrandModelProtocolFirst =>
      'Selecione primeiroo marca, modelo e protocolo.';

  @override
  String get importFromDatabaseTitle => 'Importar de a base de dados';

  @override
  String get importFromDatabaseSubtitle =>
      'Escolha un dispositivo, carga as teclas correspondentes e luego importa os botões selecionados.';

  @override
  String get deviceAndFilters => 'Dispositivo e filtros';

  @override
  String loadedCount(int count) {
    return '$count cargados';
  }

  @override
  String get hideFilters => 'Ocultar filtros';

  @override
  String get showFilters => 'Mostrar filtros';

  @override
  String get noProtocolFoundForBrandModel =>
      'Não se encontró un protocolo para esta marca e modelo.';

  @override
  String get protocolAutoDetected => 'Protocolo';

  @override
  String get protocolAutoDetectedHelper =>
      'detectado automaticamente desde a base de dados. Pode cambiarlo antes de importar.';

  @override
  String get selectBrandModelToLoadKeys =>
      'Selecione uma marca, modelo e protocolo para carregar teclas.';

  @override
  String get noKeysFound => 'Não se encontraron teclas.';

  @override
  String noKeysFoundForSearch(Object query) {
    return 'Não se encontraron teclas para \"$query\".';
  }

  @override
  String get skipDuplicates => 'Omitir duplicados';

  @override
  String get skipDuplicatesSubtitle =>
      'Não importes botões que já existan en este controle.';

  @override
  String get importSelected => 'Importar selecionados';

  @override
  String get noMacrosToExport => 'Não há macros para exporter.';

  @override
  String get macrosExportedToDownloads => 'Macros exportedas a Descargas.';

  @override
  String get failedToExportMacros => 'Não se pudieron exporter as macros.';

  @override
  String get failedToReadFile => 'Não se pudo leer o arquivo.';

  @override
  String get importFromExistingRemotesTitle =>
      'Importar desde controles existentes';

  @override
  String selectedCount(int count) {
    return '$count selecionados';
  }

  @override
  String get noOtherRemotesWithButtons =>
      'Não se encontraron otros controles con botões.';

  @override
  String get sourceRemote => 'controle origen';

  @override
  String get searchButtons => 'pesquisar botões';

  @override
  String get searchButtonsHint => 'Enc., Volume, Silencio..';

  @override
  String get selectVisible => 'Selecionar visibles';

  @override
  String get clearVisible => 'Limpiar visibles';

  @override
  String protocolNamed(Object name) {
    return 'Protocolo: $name';
  }

  @override
  String get rawSignal => 'Bruto';

  @override
  String get legacyCode => 'Código antiguo';

  @override
  String importCount(int count) {
    return 'Importar $count';
  }

  @override
  String get storagePermissionDeniedLegacy =>
      'Permissão de almacenamiento negada (necesario en algums Android antiguos).';

  @override
  String get backupExportedToDownloads => 'Cópia exporteda a Descargas.';

  @override
  String failedToExport(Object error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String importedLegacyJsonBackup(int count) {
    return 'Foram importados $count controles de uma cópia JSON antigua. Las macros não cambiaron.';
  }

  @override
  String get importFailedRemotesMustBeList =>
      'Importação falhada: \"remotes\" deve ser uma lista JSON se existe.';

  @override
  String get importFailedMacrosMustBeList =>
      'Importação falhada: \"macros\" deve ser uma lista JSON se existe.';

  @override
  String get importFailedInvalidBackupFormat =>
      'Importação falhada: formato de cópia não válido (se esperaba uma List antigua o un Map con remotes/macros).';

  @override
  String importedBackupRemotesOnly(int remoteCount) {
    return 'Foram importados $remoteCount controles de a cópia. Las macros não cambiaron.';
  }

  @override
  String importedBackupRemotesAndMacros(int remoteCount, int macroCount) {
    return 'Foram importados $remoteCount controles e $macroCount macros de a cópia.';
  }

  @override
  String get importFailedNoValidButtonsInIr =>
      'Importação falhada: não se encontraron botões válidos en o arquivo.ir.';

  @override
  String get importedOneRemoteFromFlipper =>
      'Se importó 1 controle desde Flipper.ir. Las macros não cambiaron.';

  @override
  String get importFailedInvalidIrplus =>
      'Importação falhada: arquivo irplus não válido (não se encontraron botões válidos).';

  @override
  String get importedOneRemoteFromIrplus =>
      'Se importó 1 controle desde irplus. Las macros não cambiaron.';

  @override
  String get importFailedInvalidLirc =>
      'Importação falhada: arquivo LIRC não válido (não se encontraron códigos válidos/brutos).';

  @override
  String get importedOneRemoteFromLirc =>
      'Se importó 1 controle desde uma config LIRC. Las macros não cambiaron.';

  @override
  String get unsupportedFileTypeSelected =>
      'Se seleccionó un tipo de arquivo não compatível.';

  @override
  String get importFailedInvalidUnreadableFile =>
      'Importação falhada: arquivo não válido o ilegible.';

  @override
  String get bulkImportNoSupportedFilesInFolder =>
      'Importação masiva concluída: não se encontraron arquivos compatíveis en a pasta.';

  @override
  String bulkImportNoRemotesImported(int skippedCount) {
    return 'Importação masiva concluída: não foram importados controles. Se omitieron $skippedCount arquivo(s).';
  }

  @override
  String bulkImportComplete(
    int importedCount,
    int supportedCount,
    int skippedCount,
  ) {
    return 'Importação masiva concluída: foram importados $importedCount controle(s) de $supportedCount arquivo(s) compatível(s). Se omitieron $skippedCount arquivo(s).';
  }

  @override
  String get storagePermissionDenied => 'Permissão de almacenamiento negada.';

  @override
  String get bulkImportFailedReadFolder =>
      'Importação masiva falhada: não se pudo leer o contenido de a pasta.';

  @override
  String bulkImportNoSupportedFilesSource(Object sourceLabel) {
    return 'Importação masiva concluída: não se encontraron arquivos compatíveis ($sourceLabel).';
  }

  @override
  String get clearAction => 'Limpiar';

  @override
  String get saveAction => 'Salvar';

  @override
  String buttonsTitleCount(int count) {
    return 'Botões ($count)';
  }

  @override
  String get invalidStepEncountered => 'Se encontró un passo não válido';

  @override
  String failedToSendNamed(Object name) {
    return 'Falha ao enviar: $name';
  }

  @override
  String get buttonNotFound => 'Botão não encontrado';

  @override
  String buttonNotFoundNamed(Object name) {
    return 'Botão não encontrado: $name';
  }

  @override
  String get unknownButton => 'Botão desconhecido';

  @override
  String durationSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String durationMinutesSecondsShort(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationHoursMinutesShort(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get orientationFlippedTooltip =>
      'Orientación: invertida (toca para normal)';

  @override
  String get orientationNormalTooltip =>
      'Orientación: normal (toca para inverter)';

  @override
  String get noSteps => 'Sem passos';

  @override
  String stepProgress(int current, int total) {
    return 'Passo $current / $total';
  }

  @override
  String get completed => 'Completado';

  @override
  String get paused => 'En pausa';

  @override
  String get running => 'En curso';

  @override
  String get ready => 'Listo';

  @override
  String stepsProgress(int current, int total) {
    return '$current / $total passos';
  }

  @override
  String get waiting => 'aguardando';

  @override
  String secondsRemaining(Object seconds) {
    return 'Quedan ${seconds}s';
  }

  @override
  String millisecondsShort(int ms) {
    return '${ms}ms';
  }

  @override
  String get tapContinueWhenReady =>
      'Toca Continuar quando estés listo para o seguinte passo';

  @override
  String get error => 'Error';

  @override
  String get macroCompleted => 'Macro Completado';

  @override
  String finishedIn(Object duration) {
    return 'Terminado en $duration';
  }

  @override
  String get sequence => 'Secuencia';

  @override
  String waitMilliseconds(int ms) {
    return 'Asalvar ${ms}ms';
  }

  @override
  String get runAgain => 'Executar de novo';

  @override
  String get startMacro => 'Iniciar Macro';

  @override
  String get continueAction => 'Continuar';

  @override
  String get unnamedRemote => 'Unnamed controle';

  @override
  String get enterMacroName => 'Introduza un nome para a macro';

  @override
  String get addAtLeastOneStep => 'Adicione ao menos un passo';

  @override
  String get fixInvalidSteps => 'Corrige os passos não válidos';

  @override
  String get unknownCommand => 'Desconhecido Command';

  @override
  String get unnamedCommand => 'controle sem nome';

  @override
  String get iconCommand => 'controle de icono';

  @override
  String get selectDelay => 'Selecionar Delay';

  @override
  String keepMilliseconds(int ms) {
    return 'Manter: ${ms}ms';
  }

  @override
  String get custom => 'Personalizado';

  @override
  String get enterCustomDelayDuration =>
      'Introduza uma duración personalizada de pausa';

  @override
  String millisecondsLong(int ms) {
    return '$ms milisegundos';
  }

  @override
  String secondsLong(Object seconds, Object plural) {
    return '$seconds segundo$plural';
  }

  @override
  String get customDelay => 'Pausa personalizada';

  @override
  String get delayMillisecondsLabel => 'Pausa (milisegundos)';

  @override
  String get delayMillisecondsHint => 'p. ej., 3000';

  @override
  String get recommendedDelayRange =>
      'Recommended: 250-5000ms for most dispositivos';

  @override
  String get enterValidPositiveNumber => 'Introduza un número positivo válido';

  @override
  String get ok => 'OK';

  @override
  String get remote => 'Controle';

  @override
  String get macroName => 'Nome de a macro';

  @override
  String get macroNameHint => 'e.g., i-cybie Advanced Modo';

  @override
  String stepsTitleCount(int count) {
    return 'Passos ($count)';
  }

  @override
  String get noStepsYet => 'Ainda não há passos';

  @override
  String get addCommandsAndDelaysHint =>
      'Adicione baixo controles e pausas para criar o seu secuencia';

  @override
  String get addStep => 'Adicionar passo';

  @override
  String get reorderStepsHint =>
      'Dica: arraste o asa para reordenar passos. Toca un passo para editarlo.';

  @override
  String reorderStep(int index) {
    return 'Reordenar passo $index';
  }

  @override
  String get pressAndDragToChangeStepOrder =>
      'Mantenha pressionado e arraste para cambiar o orden de os passos';

  @override
  String deleteStep(int index) {
    return 'Excluir passo $index';
  }

  @override
  String get invalidStepTapToFix => 'Passo não válido - toca para corregir';

  @override
  String get sendIrCommand => 'Enviar controle IR';

  @override
  String get waitForUserConfirmation => 'Asalvar confirmación do usuario';

  @override
  String get notImplemented => 'Não implementado';

  @override
  String frequencyKhz(int value) {
    return '$value kHz';
  }

  @override
  String get necProtocolShort => 'NEC';

  @override
  String get msbShort => 'MSB';

  @override
  String get layoutWide => 'Ancho';

  @override
  String get iconButton => 'Icon botão';

  @override
  String get imageButton => 'Image botão';

  @override
  String get noSignalInfo => 'Sem info de sinal';

  @override
  String get proceed => 'Continuar';

  @override
  String get discard => 'Descartar';

  @override
  String get continueEditing => 'Continue editing';

  @override
  String get unsavedChangesTitle => 'Unsaved changes';

  @override
  String get unsavedMacroChangesMessage =>
      'Discard your macro changes and leave this screen?';

  @override
  String get stopMacroBeforeLeaving =>
      'Stop the macro before leaving this screen.';

  @override
  String get stopTestingBeforeLeaving =>
      'Stop testing before leaving this screen.';

  @override
  String get idle => 'Inactivo';

  @override
  String get start => 'Iniciar';

  @override
  String get resume => 'retomar';

  @override
  String get pause => 'Pausa';

  @override
  String get stopped => 'Detenido';

  @override
  String get copy => 'Copiar';

  @override
  String get send => 'Enviar';

  @override
  String get step => 'Passo';

  @override
  String get addToRemote => 'Adicionar ao controle';

  @override
  String get noDescriptionAvailable => 'Não há descripción disponible.';

  @override
  String get notAvailableSymbol => '-';

  @override
  String get irFinderKaseikyoVendorInvalid =>
      'El proveedor Kaseikyo deve tener exactamente 4 dígitos hex.';

  @override
  String get irFinderDatabaseNotReady =>
      'La base de dados ainda não está lista.';

  @override
  String get irFinderSelectBrandFirst =>
      'Selecione primeiroo uma marca en Configuração.';

  @override
  String get irFinderBruteforceUnavailable =>
      'La força bruta ainda não está disponible para este protocolo.';

  @override
  String get irFinderInvalidPrefix => 'Prefijo não válido.';

  @override
  String irFinderBrandValue(Object value) {
    return 'Marca: $value';
  }

  @override
  String irFinderModelValue(Object value) {
    return 'Modelo: $value';
  }

  @override
  String irFinderKeyValue(Object value) {
    return 'Tecla: $value';
  }

  @override
  String irFinderRemoteNumber(Object value) {
    return 'controle n.º $value';
  }

  @override
  String get irFinderJumpOffsetHelper =>
      'Introduza un índice base 0 dentro de os resultados filtrados e ordenados.';

  @override
  String get irFinderJumpCursorHelper =>
      'Introduza un cursor hex base 0 dentro do espaço de força bruta.';

  @override
  String get irFinderSetupTab => 'Configuração';

  @override
  String get irFinderTestTab => 'Probar';

  @override
  String get irFinderResultsTab => 'Resultados';

  @override
  String get irFinderContinueToTest => 'Continuar a Teste';

  @override
  String get irFinderKaseikyoVendorTitle => 'Proveedor Kaseikyo';

  @override
  String get irFinderCustomVendorLabel => 'Proveedor personalizado (4 hex)';

  @override
  String get irFinderBrowseDbCandidates => 'Explorar candidatos de BD…';

  @override
  String get irFinderEditSetup => 'Editar configuração';

  @override
  String get irFinderNoSavedHits =>
      'Ainda não há aciertos guardados. En a página Teste, pulsa \"Salvar acierto\" quando o dispositivo responda.';

  @override
  String get irFinderBackToTest => 'voltar a Teste';

  @override
  String get irFinderLargeSearchSpaceTitle => 'Espaço de pesquisa grande';

  @override
  String irFinderLargeSearchSpaceBody(Object human) {
    return 'Este espaço de força bruta es muy grande ($human posibilidades). IR Finder respetará os seus intentos máximos e a espera, mas evita saturar dispositivos IR.\n\nRecomendación: usa primeiroo o modo Base de dados y/o introduza bytes de prefijo conocidos para reducir o espaço.';
  }

  @override
  String get irFinderDatabaseSession => 'Sesión de base de dados';

  @override
  String get irFinderBruteforceSession => 'Sesión de força bruta';

  @override
  String get irFinderResumeLastSession => 'retomar última sesión';

  @override
  String irFinderResumeBrandModel(Object brand, Object model) {
    return 'Marca: $brand · Modelo: $model';
  }

  @override
  String irFinderResumePrefix(Object value) {
    return 'Prefijo: $value';
  }

  @override
  String irFinderResumeProgress(Object progress, Object when) {
    return 'Progreso: $progress · Início: $when';
  }

  @override
  String get irFinderApplyResume => 'Aplicar e retomar';

  @override
  String get irFinderBruteforceMode => 'Força bruta';

  @override
  String get irFinderDatabaseAssistedMode => 'Asistido por BD';

  @override
  String irFinderProtocolTitle(Object name) {
    return 'Protocolo: $name';
  }

  @override
  String get irFinderProtocolLabel => 'Protocolo IR';

  @override
  String get irFinderProtocolHelper =>
      'Controla a codificación e por tanto o espaço de pesquisa.';

  @override
  String get irFinderKnownPrefixLabel =>
      'Prefijo conocido (bytes hex, opcional)';

  @override
  String get irFinderKnownPrefixHint => 'A1B2, A1 B2, A1:B2, 0xA1 0xB2';

  @override
  String irFinderKnownPrefixHelperPayload(int digits) {
    return 'Carga: $digits dígito(s) hex';
  }

  @override
  String irFinderKnownPrefixHelperPayloadExample(int digits, Object example) {
    return 'Carga: $digits dígito(s) hex · Ejemplo: $example';
  }

  @override
  String irFinderKnownPrefixHelperPayloadMax(int digits, int bytes) {
    return 'Carga: $digits dígito(s) hex · Prefijo máx.: $bytes byte(s)';
  }

  @override
  String irFinderKnownPrefixHelperPayloadExampleMax(
    int digits,
    Object example,
    int bytes,
  ) {
    return 'Carga: $digits dígito(s) hex · Ejemplo: $example · Prefijo máx.: $bytes byte(s)';
  }

  @override
  String irFinderKnownPrefixHelperExample(Object example) {
    return 'Ejemplo: $example';
  }

  @override
  String get irFinderKnownPrefixHelperFallback =>
      'Introduza os primeiroos bytes conocidos para reducir o espaço de pesquisa.';

  @override
  String get irFinderDatabaseMode => 'Base de dados';

  @override
  String irFinderNormalizedPrefixValue(Object value) {
    return 'Prefijo normalizado: $value';
  }

  @override
  String get irFinderNormalizedPrefix => 'Prefijo normalizado';

  @override
  String get irFinderBruteforceNotConfigured =>
      'La força bruta ainda não está configurada para este protocolo.';

  @override
  String irFinderAllLimit(Object value) {
    return 'Tudo ($value)';
  }

  @override
  String get irFinderTestControls => 'controles de teste';

  @override
  String irFinderPayloadLength(int digits) {
    return 'Longitud de carga: $digits dígito(s) hex.';
  }

  @override
  String irFinderSearchSpace(Object value) {
    return 'Espaço de pesquisa: $value posibilidades (tras as restricciones do prefijo).';
  }

  @override
  String get irFinderCooldownMs => 'Espera (ms)';

  @override
  String get irFinderMaxAttemptsPerRun => 'Intentos máx. (por execução)';

  @override
  String get irFinderTestAllCombinations => 'Probar todas as combinaciones';

  @override
  String irFinderTestAllCombinationsHint(Object value) {
    return 'Se ejecuta hasta agotar o espaço de pesquisa. Límite efectivo: $value';
  }

  @override
  String get irFinderAttempts => 'Intentos';

  @override
  String irFinderAttemptsSliderRange(int max) {
    return 'Rango do deslizador: 1–$max (escreva cualquier número para valores mayores)';
  }

  @override
  String irFinderMaxButton(int value) {
    return 'Máx.\n$value';
  }

  @override
  String irFinderEffectiveLimitThisRun(Object value) {
    return 'Límite efectivo en esta execução: $value';
  }

  @override
  String get irFinderBruteforceTip =>
      'Dica: usa primeiroo o modo Base de dados; a força bruta va melhor con un prefijo conocido (por ejemplo, os primeiroos 1–4 bytes).';

  @override
  String get irFinderDatabaseInitFailed =>
      'Falhou a inicialização de a base de dados.';

  @override
  String get irFinderPreparingDatabase =>
      'Preparando base local de códigos IR…';

  @override
  String get irFinderDatabaseAssistedSearch => 'Pesquisa asistida por BD';

  @override
  String get irFinderBrand => 'Marca';

  @override
  String get irFinderSelectBrand => 'Selecionar marca';

  @override
  String get irFinderModelOptional => 'Modelo (opcional)';

  @override
  String get irFinderSelectBrandFirstShort => 'Selecione primeiroo uma marca';

  @override
  String get irFinderSelectModelRecommended =>
      'Selecione un modelo (recomendado)';

  @override
  String get irFinderOnlySelectedProtocol => 'Apenas protocolo selecionado';

  @override
  String get irFinderOnlySelectedProtocolHint =>
      'Filtra as teclas ao protocolo escolhido. Desactívalo para ver todos os protocolos.';

  @override
  String get irFinderQuickWinsFirst => 'Aciertos rápidos primeiroo';

  @override
  String get irFinderQuickWinsFirstHint =>
      'Prioriza teclas tipo POWER, MUTE, VOL e CH antes que otras mais profundas.';

  @override
  String get irFinderMaxKeysPerRun => 'Teclas máx. a probar (por execução)';

  @override
  String get irFinderTesting => 'Probando…';

  @override
  String get irFinderCooldown => 'Espera';

  @override
  String get irFinderEta => 'ETA';

  @override
  String get irFinderMode => 'Modo';

  @override
  String get irFinderRetryLast => 'Tentar novamente a última';

  @override
  String get irFinderTrigger => 'Disparar';

  @override
  String get irFinderJump => 'Saltar…';

  @override
  String get irFinderSaveHit => 'Salvar acierto';

  @override
  String irFinderEtaSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String irFinderEtaMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String irFinderEtaHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String irFinderLastAttemptedCode(Object value) {
    return 'Último código probado: $value';
  }

  @override
  String get irFinderStartTestingToSeeLastCode =>
      'Empieza a teste para ver o último código intentado.';

  @override
  String irFinderFromDb(Object value) {
    return 'De BD: $value';
  }

  @override
  String get irFinderFromBruteforce =>
      'De força bruta (generado por o codificador de protocolo).';

  @override
  String irFinderSendError(Object error) {
    return 'Erro de envio: $error';
  }

  @override
  String irFinderSourceValue(Object value) {
    return 'Origen: $value';
  }

  @override
  String get irFinderResultsNote =>
      'Los resultados permiten Probar e Copiar ao instante. La integración directa para adicionar ao controle pode ampliarse luego en o editor.';

  @override
  String get irFinderBrowseDbCandidatesTitle => 'Explorar candidatos de BD';

  @override
  String get irFinderFilterByLabelOrHex => 'Filtrar por etiqueta o hex…';

  @override
  String get irFinderJumpHere => 'Saltar aqui';

  @override
  String get irFinderSelectModel => 'Selecionar modelo';

  @override
  String get irFinderSearchBrands => 'pesquisar marcas…';

  @override
  String get irFinderSearchModels => 'pesquisar modelos…';

  @override
  String get iconPickerTitle => 'Selecionar icono';

  @override
  String get iconPickerSearchHint => 'pesquisar iconos..';

  @override
  String get iconPickerNoIconsFound => 'Não se encontraron iconos';

  @override
  String iconPickerIconsAvailable(int count) {
    return '$count iconos disponibles';
  }

  @override
  String get iconPickerCategoryAll => 'Tudo';

  @override
  String get iconPickerCategoryMedia => 'Medios';

  @override
  String get iconPickerCategoryVolume => 'Volume';

  @override
  String get iconPickerCategoryNavigation => 'Navegación';

  @override
  String get iconPickerCategoryPower => 'Enc.';

  @override
  String get iconPickerCategoryNumbers => 'Números';

  @override
  String get iconPickerCategorySettings => 'configurações';

  @override
  String get iconPickerCategoryDisplay => 'tela';

  @override
  String get iconPickerCategoryInput => 'Entrada';

  @override
  String get iconPickerCategoryFavorite => 'Favorito';

  @override
  String get universalPowerTitle => 'conectado universal';

  @override
  String get universalPowerRunTab => 'Executar';

  @override
  String get universalPowerUseResponsibly => 'Úsalo con responsabilidad';

  @override
  String get universalPowerConsentBody =>
      'conectado universal cicla códigos IR de conectado. Úsalo apenas en dispositivos que posees o controlas. Deténlo en cuanto o dispositivo responda.';

  @override
  String get universalPowerConsentCheckbox => 'Poseo o controle o dispositivo';

  @override
  String get universalPowerSetupBody =>
      'Cicla códigos de conectado para a marca escolhida. Deténlo en cuanto o dispositivo responda.';

  @override
  String universalPowerLastSent(Object value) {
    return 'Último enviado: $value';
  }

  @override
  String get universalPowerNoCodesFound =>
      'Não se encontraron códigos de conectado. Intenta ampliar a pesquisa.';

  @override
  String get universalPowerUnableToStart => 'Não se pudo iniciar.';

  @override
  String get universalPowerAllBrands => 'Todas as marcas (sem filtro)';

  @override
  String get universalPowerClearBrandFilter => 'Limpiar filtro de marca';

  @override
  String get universalPowerBroadenSearch => 'Amplía a pesquisa se hace falta';

  @override
  String get universalPowerBroadenSearchHint =>
      'Se não se encuentran etiquetas de conectado, incluye otras teclas.';

  @override
  String get universalPowerAdditionalPatternsDepth =>
      'Profundidad de patrones extra';

  @override
  String get universalPowerDepth1 => 'Apenas prioridad: POWER/OFF';

  @override
  String get universalPowerDepth2 => 'Incluir alias de POWER';

  @override
  String get universalPowerDepth3 =>
      'Incluir etiquetas secundarias de conectado';

  @override
  String get universalPowerDepth4 =>
      'Incluir todas as etiquetas (menor prioridad)';

  @override
  String get universalPowerLoopUntilStopped => 'Repetir hasta parar';

  @override
  String get universalPowerLoopUntilStoppedHint =>
      'Segue ciclando a cola hasta que a detengas.';

  @override
  String get universalPowerDelayBetweenCodes => 'Pausa entre códigos';

  @override
  String get universalPowerStart => 'Iniciar conectado universal';

  @override
  String get universalPowerRunStatus => 'Estado de execução';

  @override
  String universalPowerProgress(Object value) {
    return 'Progreso: $value';
  }

  @override
  String get universalPowerPausedInBackground =>
      'En pausa porque o app pasó a segundo plano.';

  @override
  String get universalPowerSendOneCode => 'Enviar un código';

  @override
  String get universalPowerStopWhenDeviceResponds =>
      'Deténlo en cuanto o dispositivo responda.';

  @override
  String get iconNamePlay => 'Reproduzir';

  @override
  String get iconNamePause => 'Pausa';

  @override
  String get iconNameStop => 'parar';

  @override
  String get iconNameFastForward => 'Avance rápido';

  @override
  String get iconNameRewind => 'Rebobinar';

  @override
  String get iconNameSkipNext => 'Seguinte';

  @override
  String get iconNameSkipPrevious => 'Anterior';

  @override
  String get iconNameReplay => 'Repetir';

  @override
  String get iconNameForward10S => 'Adelante 10s';

  @override
  String get iconNameForward30S => 'Adelante 30s';

  @override
  String get iconNameReplay10S => 'Repetir 10s';

  @override
  String get iconNameReplay30S => 'Repetir 30s';

  @override
  String get iconNameRecord => 'Grabar';

  @override
  String get iconNameRecordAlt => 'Grabar Alt';

  @override
  String get iconNameEject => 'Expulsar';

  @override
  String get iconNameShuffle => 'Aleatorio';

  @override
  String get iconNameRepeat => 'Repetir';

  @override
  String get iconNameRepeatOne => 'Repetir uma';

  @override
  String get iconNameVolumeUp => 'Volume Cima';

  @override
  String get iconNameVolumeDown => 'Volume Baixo';

  @override
  String get iconNameVolumeOff => 'Volume Desconectado';

  @override
  String get iconNameMute => 'Sil.';

  @override
  String get iconNameSpeaker => 'Altavoz';

  @override
  String get iconNameSurroundSound => 'Envolvente Sonido';

  @override
  String get iconNameEqualizer => 'Ecualizador';

  @override
  String get iconNameAudio => 'áudio';

  @override
  String get iconNameMicrophone => 'Micrófono';

  @override
  String get iconNameMicOff => 'Mic Desconectado';

  @override
  String get iconNameUp => 'Cima';

  @override
  String get iconNameDown => 'Baixo';

  @override
  String get iconNameLeft => 'Esquerda';

  @override
  String get iconNameRight => 'Direita';

  @override
  String get iconNameArrowUp => 'Seta Cima';

  @override
  String get iconNameArrowDown => 'Seta Baixo';

  @override
  String get iconNameArrowLeft => 'Seta Esquerda';

  @override
  String get iconNameArrowRight => 'Seta Direita';

  @override
  String get iconNameNavigation => 'Navegación';

  @override
  String get iconNameChevronLeft => 'Chevron Esquerda';

  @override
  String get iconNameChevronRight => 'Chevron Direita';

  @override
  String get iconNameExpandLess => 'Expandir Menos';

  @override
  String get iconNameExpandMore => 'Expandir Mais';

  @override
  String get iconNameCollapse => 'Contraer';

  @override
  String get iconNameExpand => 'Expandir';

  @override
  String get iconNameCircleUp => 'Círculo Cima';

  @override
  String get iconNameCircleDown => 'Círculo Baixo';

  @override
  String get iconNameCircleLeft => 'Círculo Esquerda';

  @override
  String get iconNameCircleRight => 'Círculo Direita';

  @override
  String get iconNameOkSelect => 'OK/Selecionar';

  @override
  String get iconNameConfirm => 'Confirmar';

  @override
  String get iconNameCancel => 'Cancelar';

  @override
  String get iconNameClose => 'Fechar';

  @override
  String get iconNameHome => 'Início';

  @override
  String get iconNameReturn => 'voltar';

  @override
  String get iconNameExit => 'Salir';

  @override
  String get iconNameUndo => 'desfazer';

  @override
  String get iconNameRedo => 'Rehacer';

  @override
  String get iconNamePower => 'Enc.';

  @override
  String get iconNamePowerAlt => 'conectado Alt';

  @override
  String get iconNamePowerOff => 'Power Desconectado';

  @override
  String get iconNameOn => 'conectado';

  @override
  String get iconNameOff => 'Desconectado';

  @override
  String get iconNameToggleOn => 'Alternar conectado';

  @override
  String get iconNameToggleOff => 'Alternar desconectado';

  @override
  String get iconNameRestart => 'Reiniciar';

  @override
  String get iconNameNum1 => '1';

  @override
  String get iconNameNum2 => '2';

  @override
  String get iconNameNum3 => '3';

  @override
  String get iconNameNum4 => '4';

  @override
  String get iconNameNum5 => '5';

  @override
  String get iconNameNum6 => '6';

  @override
  String get iconNameNum7 => '7';

  @override
  String get iconNameNum8 => '8';

  @override
  String get iconNameNum9 => '9';

  @override
  String get iconNameNum92 => '9+';

  @override
  String get iconNameNum0 => '0';

  @override
  String get iconNameOne => 'Una';

  @override
  String get iconNameTwo => 'Dos';

  @override
  String get iconNameThree => 'Tres';

  @override
  String get iconNameFour => 'Cuatro';

  @override
  String get iconNameFive => 'Cinco';

  @override
  String get iconNameSix => 'Seis';

  @override
  String get iconNamePlus => 'Mais';

  @override
  String get iconNameMinus => 'Menos';

  @override
  String get iconNameAddCircle => 'Adicionar círculo';

  @override
  String get iconNameRemoveCircle => 'Remove Círculo';

  @override
  String get iconNameSettings => 'configurações';

  @override
  String get iconNameMenu => 'Menú';

  @override
  String get iconNameMoreVertical => 'Mais Vertical';

  @override
  String get iconNameMoreHorizontal => 'Mais Horizontal';

  @override
  String get iconNameTune => 'Ajuste';

  @override
  String get iconNameRemoteSettings => 'controle configurações';

  @override
  String get iconNameInfo => 'Informação';

  @override
  String get iconNameInfoOutline => 'Informação contorno';

  @override
  String get iconNameHelp => 'Ajuda';

  @override
  String get iconNameHelpOutline => 'Ajuda Contorno';

  @override
  String get iconNameList => 'Lista';

  @override
  String get iconNameViewList => 'Vista List';

  @override
  String get iconNameViewGrid => 'Vista grade';

  @override
  String get iconNameApps => 'Apps';

  @override
  String get iconNameWidgets => 'Widgets';

  @override
  String get iconNameTv => 'TV';

  @override
  String get iconNameMonitor => 'Monitor';

  @override
  String get iconNameDesktop => 'Escritorio';

  @override
  String get iconNameBrightnessHigh => 'Brilho alto';

  @override
  String get iconNameBrightnessMedium => 'Brilho medio';

  @override
  String get iconNameBrightnessLow => 'Brilho bajo';

  @override
  String get iconNameAutoBrightness => 'Brilho automático';

  @override
  String get iconNameLightMode => 'Luz Modo';

  @override
  String get iconNameDarkMode => 'Dark Modo';

  @override
  String get iconNameContrast => 'Contraste';

  @override
  String get iconNameHdrOn => 'HDR conectado';

  @override
  String get iconNameHdrOff => 'HDR Desconectado';

  @override
  String get iconNameAspectRatio => 'Relación de aspecto';

  @override
  String get iconNameCrop => 'Recortar';

  @override
  String get iconNameZoomIn => 'Acercar';

  @override
  String get iconNameZoomOut => 'Alejar';

  @override
  String get iconNameFullscreen => 'tela completa';

  @override
  String get iconNameExitFullscreen => 'Exit tela completa';

  @override
  String get iconNameFitScreen => 'Ajustar tela';

  @override
  String get iconNamePip => 'PiP';

  @override
  String get iconNameCropFree => 'Recortar Free';

  @override
  String get iconNameInput => 'Entrada';

  @override
  String get iconNameCable => 'Cable';

  @override
  String get iconNameCast => 'Transmitir';

  @override
  String get iconNameCastConnected => 'Transmitir Connected';

  @override
  String get iconNameScreenShare => 'Screen Compartir';

  @override
  String get iconNameBluetooth => 'Bluetooth';

  @override
  String get iconNameWifi => 'WiFi';

  @override
  String get iconNameRouter => 'Router';

  @override
  String get iconNameMemory => 'Memoria';

  @override
  String get iconNameGameConsole => 'Consola de juegos';

  @override
  String get iconNameGaming => 'Juegos';

  @override
  String get iconNameMedia => 'Medios';

  @override
  String get iconNameMusicQueue => 'Música Cola';

  @override
  String get iconNameVideoLibrary => 'Biblioteca de video';

  @override
  String get iconNamePhotoLibrary => 'Foto Library';

  @override
  String get iconNameComponent => 'Componente';

  @override
  String get iconNameHdmi => 'HDMI';

  @override
  String get iconNameComposite => 'Compuisto';

  @override
  String get iconNameAntenna => 'Antena';

  @override
  String get iconNameFavorite => 'Favorito';

  @override
  String get iconNameFavoriteOutline => 'Favorito Contorno';

  @override
  String get iconNameStar => 'Estrella';

  @override
  String get iconNameStarOutline => 'Estrella contorno';

  @override
  String get iconNameBookmark => 'Marcador';

  @override
  String get iconNameBookmarkOutline => 'Marcador contorno';

  @override
  String get iconNameFlag => 'Bandera';

  @override
  String get iconNameCheck => 'Marca';

  @override
  String get iconNameDone => 'Listo';

  @override
  String get iconNameDoneAll => 'Concluído Tudo';

  @override
  String get iconNameSchedule => 'Programación';

  @override
  String get iconNameTimer => 'Temporizador';

  @override
  String get iconNameTime => 'Tiempo';

  @override
  String get iconNameAlarm => 'Alarma';

  @override
  String get iconNameNotifications => 'Notificaciones';

  @override
  String get iconNameLock => 'Bloqueo';

  @override
  String get iconNameUnlock => 'Desbloquear';

  @override
  String get iconNameLight => 'Claro';

  @override
  String get iconNameLightOutline => 'Luz Contorno';

  @override
  String get iconNameWarmLight => 'Cálida Luz';

  @override
  String get iconNameSunny => 'Soleado';

  @override
  String get iconNameCloudy => 'Nublado';

  @override
  String get iconNameNight => 'Noche';

  @override
  String get iconNameFlare => 'Destello';

  @override
  String get iconNameGradient => 'Degradado';

  @override
  String get iconNameInvertColors => 'Inverter Colores';

  @override
  String get iconNamePalette => 'Paleta';

  @override
  String get iconNameColor => 'Cor';

  @override
  String get iconNameTonality => 'Tonalidad';

  @override
  String get iconNameSearch => 'buscar';

  @override
  String get iconNameRefresh => 'Atualizar';

  @override
  String get iconNameSync => 'Sincronizar';

  @override
  String get iconNameUpdate => 'Atualizar';

  @override
  String get iconNameDownload => 'Descargar';

  @override
  String get iconNameUpload => 'Subir';

  @override
  String get iconNameCloud => 'Nube';

  @override
  String get iconNameFolder => 'Pasta';

  @override
  String get iconNameDelete => 'Excluir';

  @override
  String get iconNameEdit => 'Editar';

  @override
  String get iconNameSave => 'Salvar';

  @override
  String get iconNameShare => 'Compartir';

  @override
  String get iconNamePrint => 'Imprimir';

  @override
  String get iconNameLanguage => 'Idioma';

  @override
  String get iconNameTranslate => 'Traducir';

  @override
  String get iconNameMicNone => 'Mic Ningum';

  @override
  String get iconNameSubtitles => 'Legendas';

  @override
  String get iconNameClosedCaption => 'Legendas cerrados';

  @override
  String get iconNameMusic => 'Música';

  @override
  String get iconNameMovie => 'Película';

  @override
  String get iconNameTheater => 'Teatro';

  @override
  String get iconNameLiveTv => 'En vivo TV';

  @override
  String get iconNameRadio => 'Radio';

  @override
  String get iconNameCamera => 'Câmara';

  @override
  String get iconNameVideoCamera => 'Video Câmara';

  @override
  String get iconNamePhotoCamera => 'Foto Câmara';

  @override
  String get iconNameSlowMotion => 'Lento Movimiento';

  @override
  String get iconNameSpeed => 'Velocidad';

  @override
  String get iconNameVideoSettings => 'Video configurações';

  @override
  String get iconNameAudioTrack => 'Pista de áudio';

  @override
  String get iconNameGraphicEq => 'Gráfico EQ';

  @override
  String get iconNameMusicVideo => 'Música Video';

  @override
  String get iconNamePlaylist => 'Lista';

  @override
  String get iconNameQueue => 'Cola';

  @override
  String get iconNameNum0Fa => '0 FA';

  @override
  String get iconNameNum1Fa => '1 FA';

  @override
  String get iconNameNum2Fa => '2 FA';

  @override
  String get iconNameNum3Fa => '3 FA';

  @override
  String get iconNameNum4Fa => '4 FA';

  @override
  String get iconNameNum5Fa => '5 FA';

  @override
  String get iconNameNum6Fa => '6 FA';

  @override
  String get iconNameNum7Fa => '7 FA';

  @override
  String get iconNameNum8Fa => '8 FA';

  @override
  String get iconNameNum9Fa => '9 FA';

  @override
  String get iconNameHashFa => 'Hash # FA';

  @override
  String get iconNamePercentFa => 'Porcentaje % FA';

  @override
  String get iconNameDivideFa => 'Dividir ÷ FA';

  @override
  String get iconNameMultiplyFa => 'Multiplicar × FA';

  @override
  String get iconNameEqualsFa => 'Igual = FA';

  @override
  String get iconNameNotEqualFa => 'Distinto ≠ FA';

  @override
  String get iconNameGreaterThanFa => 'Mayor que > FA';

  @override
  String get iconNameLessThanFa => 'Menos Than < FA';

  @override
  String get iconNameAsteriskFa => 'Asterisco * FA';

  @override
  String get iconNameAFa => 'A FA';

  @override
  String get iconNameBFa => 'B FA';

  @override
  String get iconNameCFa => 'C FA';

  @override
  String get iconNameDFa => 'D FA';

  @override
  String get iconNameEFa => 'E FA';

  @override
  String get iconNameFFa => 'F FA';

  @override
  String get iconNameGFa => 'G FA';

  @override
  String get iconNameHFa => 'H FA';

  @override
  String get iconNameIFa => 'I FA';

  @override
  String get iconNameJFa => 'J FA';

  @override
  String get iconNameKFa => 'K FA';

  @override
  String get iconNameLFa => 'L FA';

  @override
  String get iconNameMFa => 'M FA';

  @override
  String get iconNameNFa => 'N FA';

  @override
  String get iconNameOFa => 'O FA';

  @override
  String get iconNamePFa => 'P FA';

  @override
  String get iconNameQFa => 'Q FA';

  @override
  String get iconNameRFa => 'R FA';

  @override
  String get iconNameSFa => 'S FA';

  @override
  String get iconNameTFa => 'T FA';

  @override
  String get iconNameUFa => 'U FA';

  @override
  String get iconNameVFa => 'V FA';

  @override
  String get iconNameWFa => 'W FA';

  @override
  String get iconNameXFa => 'X FA';

  @override
  String get iconNameYFa => 'Y FA';

  @override
  String get iconNameZFa => 'Z FA';

  @override
  String get iconNamePlayFa => 'Reproduzir FA';

  @override
  String get iconNamePauseFa => 'Pausa FA';

  @override
  String get iconNameStopFa => 'parar FA';

  @override
  String get iconNamePlayFaOutline => 'Reproduzir FA Contorno';

  @override
  String get iconNamePauseFaOutline => 'Pausa FA Contorno';

  @override
  String get iconNameStopFaOutline => 'parar FA Contorno';

  @override
  String get iconNameBackwardFa => 'Atrás FA';

  @override
  String get iconNameForwardFa => 'Adelante FA';

  @override
  String get iconNamePreviousFa => 'Anterior FA';

  @override
  String get iconNameNextFa => 'Seguinte FA';

  @override
  String get iconNameRewindFa => 'Rebobinar FA';

  @override
  String get iconNameFastForwardFa => 'Avance rápido FA';

  @override
  String get iconNameRepeatFa => 'Repetir FA';

  @override
  String get iconNameShuffleFa => 'Aleatorio FA';

  @override
  String get iconNameEjectFa => 'Expulsar FA';

  @override
  String get iconNameFilmFa => 'Película FA';

  @override
  String get iconNameVideoFa => 'Video FA';

  @override
  String get iconNameMusicFa => 'Música FA';

  @override
  String get iconNameMicrophoneFa => 'Micrófono FA';

  @override
  String get iconNameCameraFa => 'Câmara FA';

  @override
  String get iconNameCameraRetroFa => 'Câmara Retro FA';

  @override
  String get iconNameVolumeHighFa => 'Volume alto FA';

  @override
  String get iconNameVolumeLowFa => 'Volume bajo FA';

  @override
  String get iconNameVolumeOffFa => 'Volume Desconectado FA';

  @override
  String get iconNameMuteFa => 'Silencio FA';

  @override
  String get iconNameMicMuteFa => 'Mic silenciado FA';

  @override
  String get iconNameHeadphonesFa => 'Auriculares FA';

  @override
  String get iconNameSpeakerFa => 'Altavoz FA';

  @override
  String get iconNameUpFa => 'Cima FA';

  @override
  String get iconNameDownFa => 'Baixo FA';

  @override
  String get iconNameLeftFa => 'Esquerda FA';

  @override
  String get iconNameRightFa => 'Direita FA';

  @override
  String get iconNameUpFaOutline => 'Cima FA Contorno';

  @override
  String get iconNameDownFaOutline => 'Baixo FA Contorno';

  @override
  String get iconNameLeftFaOutline => 'Esquerda FA Contorno';

  @override
  String get iconNameRightFaOutline => 'Direita FA Contorno';

  @override
  String get iconNameArrowUpFa => 'Seta Cima FA';

  @override
  String get iconNameArrowDownFa => 'Seta Baixo FA';

  @override
  String get iconNameArrowLeftFa => 'Seta Esquerda FA';

  @override
  String get iconNameArrowRightFa => 'Seta Direita FA';

  @override
  String get iconNameChevronUpFa => 'Chevron Cima FA';

  @override
  String get iconNameChevronDownFa => 'Chevron Baixo FA';

  @override
  String get iconNameChevronLeftFa => 'Chevron Esquerda FA';

  @override
  String get iconNameChevronRightFa => 'Chevron Direita FA';

  @override
  String get iconNameOkFa => 'OK FA';

  @override
  String get iconNameOkFaOutline => 'OK FA Contorno';

  @override
  String get iconNameCheckFa => 'Marca FA';

  @override
  String get iconNameCloseFa => 'Fechar FA';

  @override
  String get iconNameCloseCircleFa => 'Close Círculo FA';

  @override
  String get iconNameHomeFa => 'Início FA';

  @override
  String get iconNameUndoFa => 'desfazer FA';

  @override
  String get iconNameRedoFa => 'Rehacer FA';

  @override
  String get iconNameRotateFa => 'Girar FA';

  @override
  String get iconNameSearchFa => 'pesquisar FA';

  @override
  String get iconNameRefreshFa => 'Atualizar FA';

  @override
  String get iconNamePowerOffFa => 'Power Desconectado FA';

  @override
  String get iconNamePlugFa => 'Enchufe FA';

  @override
  String get iconNameToggleOnFa => 'Alternar conectado FA';

  @override
  String get iconNameToggleOffFa => 'Alternar desconectado FA';

  @override
  String get iconNameSettingsFa => 'configurações FA';

  @override
  String get iconNameSettingsAltFa => 'configurações Alt FA';

  @override
  String get iconNameMenuFa => 'Menú FA';

  @override
  String get iconNameMoreFa => 'Mais FA';

  @override
  String get iconNameMoreVerticalFa => 'Mais Vertical FA';

  @override
  String get iconNameInfoFa => 'Informação FA';

  @override
  String get iconNameInfoFaOutline => 'Informação FA contorno';

  @override
  String get iconNameHelpFa => 'Ajuda FA';

  @override
  String get iconNameHelpFaOutline => 'Ajuda FA Contorno';

  @override
  String get iconNameListFa => 'Lista FA';

  @override
  String get iconNameGridFa => 'grade FA';

  @override
  String get iconNameSlidersFa => 'Deslizadores FA';

  @override
  String get iconNameTvFa => 'TV FA';

  @override
  String get iconNameMonitorFa => 'Monitor FA';

  @override
  String get iconNameDesktopFa => 'Escritorio FA';

  @override
  String get iconNameBrightnessFa => 'Brilho FA';

  @override
  String get iconNameNightModeFa => 'Noche Modo FA';

  @override
  String get iconNameLightFa => 'Luz FA';

  @override
  String get iconNameLightFaOutline => 'Luz FA Contorno';

  @override
  String get iconNameFlashFa => 'Flash FA';

  @override
  String get iconNameFullscreenFa => 'tela completa FA';

  @override
  String get iconNameExitFullscreenFa => 'Exit tela completa FA';

  @override
  String get iconNameZoomInFa => 'Acercar FA';

  @override
  String get iconNameZoomOutFa => 'Alejar FA';

  @override
  String get iconNameSubtitlesFa => 'Legendas FA';

  @override
  String get iconNamePictureInPictureFa => 'Imagem en imagem FA';

  @override
  String get iconNameColorFa => 'Cor FA';

  @override
  String get iconNamePaintFa => 'Pintura FA';

  @override
  String get iconNameInputFa => 'Entrada FA';

  @override
  String get iconNameWifiFa => 'WiFi FA';

  @override
  String get iconNameBluetoothFa => 'Bluetooth FA';

  @override
  String get iconNameUsbFa => 'USB FA';

  @override
  String get iconNameEthernetFa => 'Ethernet FA';

  @override
  String get iconNameGamepadFa => 'controle FA';

  @override
  String get iconNameBroadcastFa => 'Emisión FA';

  @override
  String get iconNameSatelliteFa => 'Satellite FA';

  @override
  String get iconNameAntennaFa => 'Antenna FA';

  @override
  String get iconNameNetworkFa => 'Red FA';

  @override
  String get iconNameCloudFa => 'Nube FA';

  @override
  String get iconNameStarFa => 'Estrella FA';

  @override
  String get iconNameStarFaOutline => 'Estrella FA contorno';

  @override
  String get iconNameHeartFa => 'Corazón FA';

  @override
  String get iconNameHeartFaOutline => 'Heart FA Contorno';

  @override
  String get iconNameBookmarkFa => 'Marcador FA';

  @override
  String get iconNameBookmarkFaOutline => 'Marcador FA contorno';

  @override
  String get iconNameFlagFa => 'Bandera FA';

  @override
  String get iconNameClockFa => 'Reloj FA';

  @override
  String get iconNameClockFaOutline => 'Clock FA Contorno';

  @override
  String get iconNameBellFa => 'Campana FA';

  @override
  String get iconNameBellFaOutline => 'Bell FA Contorno';

  @override
  String get iconNameTimerFa => 'Temporizador FA';

  @override
  String get iconNameLockFa => 'Bloqueo FA';

  @override
  String get iconNameUnlockFa => 'Desbloquear FA';

  @override
  String get iconNameGalleryFa => 'Galería FA';

  @override
  String get iconNameImagesFa => 'Imagens FA';

  @override
  String get iconNameImageFa => 'Imagem FA';

  @override
  String get iconNameVideoFileFa => 'arquivo de video FA';

  @override
  String get iconNameAudioFileFa => 'arquivo de áudio FA';

  @override
  String get iconNamePlayOutlineFa => 'Reproduzir Contorno FA';

  @override
  String get iconNamePlaySimpleFa => 'Reproduzir simple FA';

  @override
  String get iconNamePauseSimpleFa => 'Pausa simple FA';

  @override
  String get iconNameStopSimpleFa => 'parar simple FA';

  @override
  String get iconNameRecordFa => 'Grabar FA';

  @override
  String get iconNameStopCircleFa => 'parar Círculo FA';

  @override
  String get iconNameLoadingFa => 'Cargando FA';

  @override
  String get iconNameTextFa => 'Texto FA';

  @override
  String get iconNameTextSizeFa => 'Texto Tamanho FA';

  @override
  String get iconNameLanguageFa => 'Idioma FA';

  @override
  String get iconNameGlobeFa => 'Globo FA';

  @override
  String get iconNameSubtitlesAltFa => 'Legendas Alt FA';

  @override
  String get iconNameSubtitlesAltOutlineFa => 'Legendas Alt Contorno FA';

  @override
  String get iconNameChannelUpFa => 'Canal Cima FA';

  @override
  String get iconNameChannelDownFa => 'Canal Baixo FA';

  @override
  String get iconNamePageUpFa => 'Página Cima FA';

  @override
  String get iconNamePageDownFa => 'Página Baixo FA';

  @override
  String get iconNameGuideFa => 'Guía FA';

  @override
  String get iconNameGridViewFa => 'grade Vista FA';

  @override
  String get iconNameGridAltFa => 'grade Alt FA';

  @override
  String get iconNameScheduleFa => 'Programación FA';

  @override
  String get iconNameCalendarFa => 'Calendario FA';

  @override
  String get iconNameRedButtonFa => 'Rojo Botão FA';

  @override
  String get iconNameButtonOutlineFa => 'Botão Contorno FA';

  @override
  String get iconNameSquareButtonFa => 'Quadrado Botão FA';

  @override
  String get iconNameSquareOutlineFa => 'Quadrado Contorno FA';

  @override
  String get iconNameDotCircleFa => 'Punto Círculo FA';

  @override
  String get iconNameToolsFa => 'Herramientas FA';

  @override
  String get iconNameScrewdriverFa => 'Distornillador FA';

  @override
  String get iconNameHammerFa => 'Martillo FA';

  @override
  String get iconNameToolboxFa => 'Caja de herramientas FA';

  @override
  String get iconNameCogFa => 'Engrane FA';

  @override
  String get iconNameAdjustFa => 'Ajustar FA';

  @override
  String get iconNameFilterFa => 'Filtro FA';

  @override
  String get iconNameSortDownFa => 'Ordenar Baixo FA';

  @override
  String get iconNameSortUpFa => 'Ordenar Cima FA';

  @override
  String get iconNameSleepFa => 'Reposo FA';

  @override
  String get iconNameTimerStartFa => 'Temporizador Iniciar FA';

  @override
  String get iconNameTimerHalfFa => 'Temporizador Mitad FA';

  @override
  String get iconNameTimerEndFa => 'Temporizador Fin FA';

  @override
  String get iconNameStopwatchFa => 'Cronómetro FA';

  @override
  String get iconNameAlarmFa => 'Alarma FA';

  @override
  String get iconNameCropAltFa => 'Recortar Alt FA';

  @override
  String get iconNameCropFa => 'Recortar FA';

  @override
  String get iconNameSquareFullFa => 'Quadrado Completo FA';

  @override
  String get iconNameFullscreenAltFa => 'tela completa Alt FA';

  @override
  String get iconNameZoomPlusFa => 'Zoom Mais FA';

  @override
  String get iconNameZoomMinusFa => 'Zoom Menos FA';

  @override
  String get iconNameMusicNoteFa => 'Música Nota FA';

  @override
  String get iconNameCdFa => 'CD FA';

  @override
  String get iconNameVinylFa => 'Vinilo FA';

  @override
  String get iconNameRssFa => 'RSS FA';

  @override
  String get iconNameMagicFa => 'Mágico FA';

  @override
  String get iconNameFingerprintFa => 'Huella FA';

  @override
  String get iconNameUserFa => 'Usuario FA';

  @override
  String get iconNameUsersFa => 'Usuarios FA';

  @override
  String get iconNameChildModeFa => 'Niño Modo FA';

  @override
  String get iconNameCastFa => 'Transmitir FA';

  @override
  String get iconNameStreamFa => 'Flujo FA';

  @override
  String get iconNameSignalFa => 'Sinal FA';

  @override
  String get iconNameFeedFa => 'Feed FA';

  @override
  String get iconNameCircleArrowUpFa => 'Círculo Seta Cima FA';

  @override
  String get iconNameCircleArrowDownFa => 'Círculo Seta Baixo FA';

  @override
  String get iconNameCircleArrowLeftFa => 'Círculo Seta Esquerda FA';

  @override
  String get iconNameCircleArrowRightFa => 'Círculo Seta Direita FA';

  @override
  String get iconNameLongArrowUpFa => 'Largo Seta Cima FA';

  @override
  String get iconNameLongArrowDownFa => 'Largo Seta Baixo FA';

  @override
  String get iconNameLongArrowLeftFa => 'Largo Seta Esquerda FA';

  @override
  String get iconNameLongArrowRightFa => 'Largo Seta Direita FA';

  @override
  String get iconNamePlusFa => 'Mais FA';

  @override
  String get iconNameMinusFa => 'Menos FA';

  @override
  String get iconNamePlusCircleFa => 'Mais Círculo FA';

  @override
  String get iconNameMinusCircleFa => 'Menos Círculo FA';

  @override
  String get iconNamePlusSquareFa => 'Mais Quadrado FA';

  @override
  String get iconNameMinusSquareFa => 'Menos Quadrado FA';

  @override
  String get iconNameTimesFa => 'Veces FA';

  @override
  String get iconNameTimesCircleFa => 'Veces Círculo FA';

  @override
  String get iconNameBatteryFullFa => 'Batería Completo FA';

  @override
  String get iconNameBattery34Fa => 'Batería 3/4 FA';

  @override
  String get iconNameBatteryHalfFa => 'Batería Mitad FA';

  @override
  String get iconNameBattery14Fa => 'Batería 1/4 FA';

  @override
  String get iconNameBatteryEmptyFa => 'Batería Empty FA';

  @override
  String get iconNameChargingFa => 'Cargando FA';

  @override
  String get iconNameCloudSunFa => 'Nube Sol FA';

  @override
  String get iconNameCloudMoonFa => 'Nube Luma FA';

  @override
  String get iconNameRainFa => 'Lluvia FA';

  @override
  String get iconNameSnowflakeFa => 'Copo FA';

  @override
  String get iconNameFireFa => 'Fuego FA';

  @override
  String get iconNameTemperatureFa => 'Temperatura FA';

  @override
  String get iconNameBoxFa => 'Caja FA';

  @override
  String get iconNameGiftFa => 'Regalo FA';

  @override
  String get iconNameTrophyFa => 'Trofeo FA';

  @override
  String get iconNameCrownFa => 'Corona FA';

  @override
  String get iconNameGemFa => 'Gema FA';

  @override
  String get unknownLabel => 'Desconhecido';

  @override
  String get selectedFilesLabel => 'arquivo(s) selecionado(s)';

  @override
  String get folderNotFoundOrInaccessible =>
      'Pasta não encontrada o inaccesible.';

  @override
  String get importedRemoteDefaultName => 'MandoImportado';

  @override
  String get demoRemoteName => 'controle demo';

  @override
  String get protocolFieldsInvalid =>
      'Rellena os campos obrigatórios do protocolo e asegúrate de que a frecuencia sea 15k–60k se se define.';

  @override
  String get unknownProtocolSelected =>
      'Se seleccionó un protocolo desconhecido.';

  @override
  String get continueSectionTitle => 'Continue';

  @override
  String get continueSectionSubtitle => 'Pick up where you left off.';

  @override
  String get continueLastRemoteTitle => 'Last remote';

  @override
  String get continueLastMacroTitle => 'Last macro';

  @override
  String get continueLastIrFinderHitTitle => 'Last IR Finder hit';

  @override
  String get continueTargetUnavailable => 'That item is no longer available.';

  @override
  String get continueUniversalPowerAllBrands => 'All brands';

  @override
  String get untitledMacro => 'Untitled Macro';

  @override
  String get pinnedRemotesTitle => 'Pinned remotes';

  @override
  String get pinnedRemotesSubtitle =>
      'Keep your most important remotes one tap away.';

  @override
  String get recentlyUsedRemotesTitle => 'Recently used';

  @override
  String get recentlyUsedRemotesSubtitle =>
      'Jump back into the remotes you opened most recently.';

  @override
  String get pinRemote => 'Pin remote';

  @override
  String get unpinRemote => 'Unpin remote';

  @override
  String get pinRemoteSubtitle =>
      'Keep this remote at the top for faster access.';

  @override
  String get remoteAddedToPinned => 'Remote pinned.';

  @override
  String get remoteRemovedFromPinned => 'Remote removed from pinned.';

  @override
  String get homeDeviceControlsTitle => 'Quick controls';

  @override
  String get homeDeviceControlsSubtitle =>
      'Power, mute, and volume without opening a remote.';

  @override
  String get homeDeviceControlsEmptySubtitle =>
      'Set up power, mute, and volume buttons in Device Controls.';

  @override
  String get showDeviceControlsOnHome => 'Show quick controls on home';

  @override
  String get showDeviceControlsOnHomeSubtitle =>
      'Show the compact Power, Mute, and Volume row on the main screen.';

  @override
  String get homeDeviceControlsShown => 'Quick controls shown on home.';

  @override
  String get homeDeviceControlsHidden => 'Quick controls hidden from home.';

  @override
  String get power => 'Power';

  @override
  String get mute => 'Mute';

  @override
  String get volumeUp => 'Vol +';

  @override
  String get volumeDown => 'Vol -';

  @override
  String get manage => 'Manage';

  @override
  String get hide => 'Hide';

  @override
  String get lastActionTitle => 'Last action';

  @override
  String lastActionSent(String title) {
    return 'Sent $title';
  }

  @override
  String lastActionSentTo(String remoteName, String title) {
    return 'Sent $remoteName -> $title';
  }

  @override
  String get repeatAction => 'Repeat';

  @override
  String get globalSearchTitle => 'Search everything';

  @override
  String get globalSearchNoResults => 'No results found.';

  @override
  String get globalSearchTypeRemote => 'REMOTE';

  @override
  String get globalSearchTypeButton => 'BUTTON';

  @override
  String get globalSearchTypeMacro => 'MACRO';

  @override
  String get learningModeCaptureFailed => 'A captura de aprendizagem falhou.';

  @override
  String get learningModeReplaySent => 'Sinal aprendido repetido.';

  @override
  String get learningModeReplayFailed =>
      'O sinal aprendido não pôde ser reproduzido.';

  @override
  String get learningModeNoRemotesAvailable =>
      'Ainda não há controles remotos salvos.';

  @override
  String get learningModeChooseRemoteTitle => 'Escolha um controle remoto';

  @override
  String get learningModeNewRemoteTitle => 'Crie um novo controle remoto';

  @override
  String get learningModeSaveSuccess => 'Botão aprendido salvo.';

  @override
  String get learningModeSaveFailed => 'O botão aprendido não pôde ser salvo.';

  @override
  String get remoteSetupIntro =>
      'Escolha primeiro um nome e um layout. Depois você poderá adicionar botões.';

  @override
  String get startWithDefault => 'Começar com o padrão';

  @override
  String get browseGithubStore => 'Explorar GitHub Store';

  @override
  String get addFirstButton => 'Adicionar primeiro botão';

  @override
  String get moreWaysToStart => 'Mais formas de começar';

  @override
  String get unsavedRemoteSetupChangesMessage =>
      'Descartar esta nova configuração do controle e sair desta tela?';

  @override
  String get unsavedRemoteStudioChangesMessage =>
      'Descartar as alterações do controle e sair desta tela?';

  @override
  String get firstButtonAdded => 'Primeiro botão adicionado.';

  @override
  String get iconColorTitle => 'Cor do ícone';

  @override
  String get iconColorHelper =>
      'Escolha uma cor para o símbolo que continue visível sobre o fundo do botão.';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorDeepPurple => 'Roxo escuro';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorLightBlue => 'Azul claro';

  @override
  String get colorCyan => 'Ciano';

  @override
  String get colorTeal => 'Verde-azulado';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorLightGreen => 'Verde claro';

  @override
  String get colorLime => 'Lima';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorAmber => 'Âmbar';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorDeepOrange => 'Laranja escuro';

  @override
  String get colorBrown => 'Marrom';

  @override
  String get colorGrey => 'Cinza';

  @override
  String get colorBlueGrey => 'Cinza azulado';

  @override
  String get colorBlack => 'Preto';

  @override
  String get colorWhite => 'Branco';

  @override
  String buttonColorSemantics(Object colorName) {
    return 'Cor do botão $colorName';
  }

  @override
  String buttonColorSemanticsSelected(Object colorName) {
    return 'Cor do botão $colorName, selecionada';
  }

  @override
  String iconColorSemantics(Object colorName) {
    return 'Cor do ícone $colorName';
  }

  @override
  String iconColorSemanticsSelected(Object colorName) {
    return 'Cor do ícone $colorName, selecionada';
  }

  @override
  String get usbDevInfoAppTitle => 'Info USB';

  @override
  String get navigationErrorTitle => 'Erro de navegação';

  @override
  String get homeHistoryTooltip => 'Histórico';

  @override
  String get homeSettingsTooltip => 'Configurações';

  @override
  String get homeSearchHint =>
      'Pesquisar fornecedor, produto, VID:PID, caminho do dispositivo…';

  @override
  String get homeClearSearchTooltip => 'Limpar';

  @override
  String get homeInputDeviceLabel => 'Dispositivo de entrada';

  @override
  String get homeUsbDeviceLabel => 'Dispositivo USB';

  @override
  String get homeUnknownVendor => 'Fornecedor desconhecido';

  @override
  String get homeSysfsTopology => 'Topologia sysfs';

  @override
  String get homePermissionGranted => 'Permissão concedida';

  @override
  String get homeNeedsPermission => 'Precisa de permissão';

  @override
  String get homeHiddenTopology => 'Topologia oculta';

  @override
  String get homeInputPath => 'Caminho de entrada';

  @override
  String get homeNoUsbDevicesTitle => 'Nenhum dispositivo USB detectado';

  @override
  String get homeNoUsbDevicesBody =>
      'Conecte um dispositivo USB (OTG) ou um acessório USB e depois puxe para atualizar.\n\nDica: conceda permissão por dispositivo para ler strings, analisar descritores brutos e enumerar configurações, interfaces e endpoints completos.';

  @override
  String homeInterfacesCount(int count) {
    return '$count interfaces';
  }

  @override
  String homeInputSourcesLabel(Object sources) {
    return 'Entrada: $sources';
  }

  @override
  String homeFailedToLoad(Object error) {
    return 'Falha ao carregar dispositivos:\n$error';
  }

  @override
  String get historyScreenTitle => 'Histórico';

  @override
  String get historyClearAllTooltip => 'Limpar tudo';

  @override
  String get historyPreviouslyInspectedTitle =>
      'Dispositivos inspecionados anteriormente';

  @override
  String get historyNothingRecordedYet => 'Ainda nada registrado';

  @override
  String get historyRecordedSingle => '1 item registrado';

  @override
  String historyRecordedCount(int count) {
    return '$count itens registrados';
  }

  @override
  String get historyOpenDevicePageHint =>
      'Abra uma página de informações do dispositivo para registrá-lo aqui.';

  @override
  String get historySwipeToDeleteHint =>
      'Deslize para a esquerda para excluir. Use Desfazer para restaurar.';

  @override
  String get historySearchHint => 'Pesquisar nome, VID:PID, serial, caminho…';

  @override
  String get historyRemovedMessage => 'Removido do histórico';

  @override
  String get historyClearDialogTitle => 'Limpar histórico?';

  @override
  String get historyClearDialogBody =>
      'Isso removerá todos os dispositivos registrados.';

  @override
  String get historyClearAllAction => 'Limpar tudo';

  @override
  String get historyConnected => 'Conectado';

  @override
  String get historyNotConnected => 'Desconectado';

  @override
  String get historyPermissionLabel => 'Permissão';

  @override
  String get historyActionsTooltip => 'Ações';

  @override
  String get historyNoMatchesTitle => 'Sem resultados';

  @override
  String get historyNoHistoryTitle => 'Ainda sem histórico';

  @override
  String get historyNoMatchesBody => 'Tente outro termo de pesquisa.';

  @override
  String get historyNoHistoryBody =>
      'Abra uma página de informações do dispositivo para registrar uma entrada aqui.';

  @override
  String historyQueryLabel(Object query) {
    return 'Consulta: \"$query\"';
  }

  @override
  String historyFailedToLoad(Object error) {
    return 'Falha ao carregar o histórico:\n$error';
  }

  @override
  String get usbSettingsSupportSubtitle =>
      'Mantenha este app rápido, livre e mantido';

  @override
  String get usbSettingsSupportBody =>
      'Sem anúncios, sem rastreamento, totalmente offline. Seu apoio ajuda a financiar manutenção, correções de compatibilidade USB e atualizações mais rápidas da base de dados USB IDs.';

  @override
  String get usbSettingsSupportPillLightweight => 'Leve';

  @override
  String get usbUseDynamicColorsSubtitle =>
      'Combina com a paleta Material You no Android 12+. Desative para usar a paleta do app.';

  @override
  String get usbAboutFailedToOpenLink => 'Falha ao abrir o link';

  @override
  String usbAboutVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get usbAboutLinksTitle => 'Links';

  @override
  String get usbAboutLinksSubtitle => 'Repositório, problemas e doações';

  @override
  String get usbAboutRepositoryTitle => 'Repositório';

  @override
  String get usbAboutReportIssueTitle => 'Reportar um problema';

  @override
  String get usbAboutIssuesLinkCopied => 'Link de problemas copiado';

  @override
  String get usbAboutDonateTitle => 'Doar via Liberapay';

  @override
  String get usbAboutLiberapayLinkCopied => 'Link do Liberapay copiado';

  @override
  String get usbAboutWhatThisAppIsTitle => 'O que é este app';

  @override
  String get usbAboutWhatThisAppIsSubtitle => 'Utilitário de inspeção USB';

  @override
  String get usbAboutWhatThisAppIsBody =>
      'O USBDevInfo enumera dispositivos OTG/USB host, mostra descritores e detalhes de classe/protocolo, resolve VID/PID usando uma base de dados USB IDs offline e registra o histórico de conexão. Sem contas, sem rastreamento, sem anúncios.';

  @override
  String get usbAboutUsbHostPill => 'USB host';

  @override
  String get usbAboutDescriptorsPill => 'Descritores';

  @override
  String get usbAboutOfflineUsbIdsPill => 'USB IDs offline';

  @override
  String get usbAboutBuildInformationTitle => 'Informações de compilação';

  @override
  String get usbAboutBuildInformationSubtitle =>
      'Versão, pacote e modo de compilação';

  @override
  String get usbAboutAppLabel => 'App';

  @override
  String get usbAboutVersionLabel => 'Versão';

  @override
  String get usbAboutPackageLabel => 'Pacote';

  @override
  String get usbAboutBuildLabel => 'Build';

  @override
  String get usbAboutBuildModeRelease => 'Release';

  @override
  String get usbAboutBuildModeProfile => 'Perfil';

  @override
  String get usbAboutBuildModeDebug => 'Debug';

  @override
  String get usbAboutOtherAppsTitle => 'Outros apps da KaijinLab';

  @override
  String get usbAboutOtherAppsSubtitle =>
      'Mais ferramentas ligadas a segurança e hardware';

  @override
  String get usbAboutOpenGithubRepository => 'Abrir repositório no GitHub';

  @override
  String get usbAboutLegalTitle => 'Informações legais';

  @override
  String get usbAboutLegalSubtitle => 'Licenças open source e agradecimentos';

  @override
  String get usbAboutViewThirdPartyLicenses =>
      'Ver licenças de dependências de terceiros';

  @override
  String get usbAboutCopyBuildDetailsTitle => 'Copiar detalhes da compilação';

  @override
  String get usbAboutCopyBuildDetailsSubtitle =>
      'Versão + pacote + modo de compilação';

  @override
  String get usbAboutBuildDetailsCopied => 'Detalhes da compilação copiados';

  @override
  String usbAboutCopyright(int year) {
    return '© $year KaijinLab • Software open source';
  }

  @override
  String get unavailable => 'Indisponível';

  @override
  String get deviceInfoTitle => 'Informações do dispositivo';

  @override
  String get deviceAdvancedRawViewTooltip => 'Visualização bruta avançada';

  @override
  String get deviceExportRawDumpTooltip => 'Exportar dump bruto';

  @override
  String get deviceUnableToReadDetails =>
      'Não foi possível ler os detalhes do dispositivo.';

  @override
  String get deviceAudioClassDescriptorsTitle =>
      'Descritores de classe de áudio';

  @override
  String get deviceVideoClassDescriptorsTitle =>
      'Descritores de classe de vídeo';

  @override
  String get deviceCdcSerialDescriptorsTitle => 'Descritores CDC / seriais';

  @override
  String get deviceHubDescriptorsTitle => 'Descritores de hub';

  @override
  String get deviceBosCapabilitiesTitle => 'BOS & capabilities';

  @override
  String get deviceIdentityTitle => 'Identidade';

  @override
  String get deviceIdentitySubtitle =>
      'IDs, cadeias de fornecedor/produto e continuidade';

  @override
  String get deviceVendorIdLabel => 'ID do fornecedor';

  @override
  String get deviceProductIdLabel => 'ID do produto';

  @override
  String get deviceVendorLabel => 'Fornecedor';

  @override
  String get deviceProductLabel => 'Produto';

  @override
  String get deviceChipsetFamilyLabel => 'Família do chipset';

  @override
  String get deviceChipsetBasisLabel => 'Chipset basis';

  @override
  String get deviceLikelyFunctionLabel => 'Função provável';

  @override
  String get deviceFunctionBasisLabel => 'Function basis';

  @override
  String get deviceSerialLabel => 'Número de série';

  @override
  String get deviceStableIdentityLabel => 'Identidade estável';

  @override
  String get deviceIdentityConfidenceLabel => 'Confiabilidade da identidade';

  @override
  String get deviceIdentityStrategyLabel => 'Estratégia de identidade';

  @override
  String get devicePhysicalLocationLabel => 'Localização física';

  @override
  String get deviceInterfaceFingerprintLabel => 'Impressão da interface';

  @override
  String get devicePathContinuityLabel => 'Continuidade do caminho';

  @override
  String get deviceNoPreviousPathRecorded => 'No previous device path recorded';

  @override
  String get devicePreviousPathsLabel => 'Caminhos anteriores';

  @override
  String get deviceUsbSpecificationTitle => 'Especificação USB';

  @override
  String get deviceUsbSpecificationSubtitle =>
      'Versão, velocidade, classe/protocolo';

  @override
  String get deviceUsbVersionLabel => 'Versão USB';

  @override
  String get deviceSpeedLabel => 'Velocidade';

  @override
  String get deviceDeviceClassLabel => 'Classe do dispositivo';

  @override
  String get deviceSubclassLabel => 'Subclasse';

  @override
  String get deviceProtocolLabel => 'Protocolo';

  @override
  String get deviceInterfacesLabel => 'Interfaces';

  @override
  String get deviceConfigurationsLabel => 'Configurações';

  @override
  String get deviceLocationTitle => 'Localização';

  @override
  String get deviceLocationSubtitle =>
      'Identificadores do Android e dicas do barramento';

  @override
  String get devicePathLabel => 'Caminho do dispositivo';

  @override
  String get deviceAndroidDeviceIdLabel => 'deviceId do Android';

  @override
  String get devicePortNumberLabel => 'Número da porta';

  @override
  String get deviceTypeLabel => 'Tipo';

  @override
  String get deviceTypeInputManager =>
      'Dispositivo de entrada (teclado/mouse via InputManager)';

  @override
  String get deviceTypeSysfs => 'Entrada da topologia USB (sysfs)';

  @override
  String get deviceTypeUsbManager => 'Dispositivo USB (UsbManager)';

  @override
  String get deviceTopologyTitle => 'Topologia';

  @override
  String get deviceTopologySubtitle =>
      'Layout do barramento, cadeia, pai e irmãos';

  @override
  String get deviceSourceLabel => 'Source';

  @override
  String get deviceSysfsNameLabel => 'Sysfs name';

  @override
  String get deviceSysfsPathLabel => 'Sysfs path';

  @override
  String get deviceDeviceNodeLabel => 'Device node';

  @override
  String get deviceParentLabel => 'Parent';

  @override
  String get deviceUpstreamHubLabel => 'Upstream hub';

  @override
  String get deviceBusNumberLabel => 'Bus number';

  @override
  String get deviceDeviceNumberLabel => 'Device number';

  @override
  String get deviceTreeDepthLabel => 'Tree depth';

  @override
  String get devicePortChainLabel => 'Port chain';

  @override
  String get deviceDevpathLabel => 'Devpath';

  @override
  String get deviceAuthorizedLabel => 'Authorized';

  @override
  String get deviceRemovableLabel => 'Removable';

  @override
  String get deviceMaxChildLabel => 'Max child';

  @override
  String get devicePathShortLabel => 'Path';

  @override
  String get deviceSiblingDevicesTitle => 'Sibling devices';

  @override
  String get deviceDownstreamChildrenTitle => 'Downstream children';

  @override
  String get deviceDescriptorTitle => 'Descritor do dispositivo';

  @override
  String get deviceDescriptorSubtitle => 'Campos brutos do descritor USB';

  @override
  String get deviceShowDescriptorFields => 'Mostrar campos do descritor';

  @override
  String get deviceUsbSpecBcdLabel => 'USB spec (bcdUSB)';

  @override
  String get deviceReleaseBcdLabel => 'Device release (bcdDevice)';

  @override
  String get deviceEp0MaxPacketLabel => 'EP0 max packet';

  @override
  String get deviceNumConfigurationsLabel => 'Num configurations';

  @override
  String get deviceIManufacturerLabel => 'iManufacturer';

  @override
  String get deviceIProductLabel => 'iProduct';

  @override
  String get deviceISerialNumberLabel => 'iSerialNumber';

  @override
  String get deviceUsbAudioTitle => 'Áudio USB';

  @override
  String get deviceUsbAudioSubtitle =>
      'Metadados de endpoint do AudioManager / AudioDeviceInfo';

  @override
  String get deviceUsbAudioClassLabel => 'USB audio class';

  @override
  String get devicePlatformAudioApiLabel => 'Platform audio API';

  @override
  String get deviceAvailable => 'Available';

  @override
  String get deviceConnectedUsbAudioEndpointsLabel =>
      'Endpoints de áudio USB conectados';

  @override
  String get deviceMatchedEndpointsLabel => 'Endpoints correspondentes';

  @override
  String get deviceAudioManagerUnavailableNote =>
      'Os dados do AudioManager não estão disponíveis nesta versão do Android ou neste dispositivo.';

  @override
  String get deviceNoAudioEndpointMatchedNote =>
      'Ainda não foi possível associar nenhum endpoint AudioDeviceInfo a este dispositivo USB.';

  @override
  String get deviceAndroidNoMatchedAudioEndpointNote =>
      'O Android não informa nenhum endpoint de áudio USB correspondente para este dispositivo.';

  @override
  String get deviceUsbMidiTitle => 'MIDI USB';

  @override
  String get deviceUsbMidiSubtitle =>
      'Metadados de dispositivo e porta do MidiManager';

  @override
  String get deviceProbableUsbMidiInterfaceLabel =>
      'Interface USB MIDI provável';

  @override
  String get devicePlatformMidiApiLabel => 'API MIDI da plataforma';

  @override
  String get deviceConnectedMidiDevicesLabel => 'Dispositivos MIDI conectados';

  @override
  String get deviceMatchedMidiDevicesLabel =>
      'Dispositivos MIDI correspondentes';

  @override
  String get deviceMidiManagerUnavailableNote =>
      'Os dados do MidiManager não estão disponíveis nesta versão do Android ou neste dispositivo.';

  @override
  String get deviceDescriptorsLookLikeMidiNote =>
      'Os descritores USB parecem MIDI, mas o Android não expôs um dispositivo MidiManager correspondente.';

  @override
  String get deviceAndroidNoMatchedMidiDeviceNote =>
      'O Android não informa nenhum dispositivo MIDI correspondente para este dispositivo USB.';

  @override
  String get devicePowerTitle => 'Energia';

  @override
  String get devicePowerSubtitle => 'Orçamento de energia da configuração';

  @override
  String get deviceMaxPowerConfig0Label => 'Max power (config 0)';

  @override
  String get deviceConfigurationsTitle => 'Configurações';

  @override
  String get deviceConfigurationsSubtitle =>
      'Todas as configurações USB reportadas';

  @override
  String get deviceInterfacesEndpointsTitle => 'Interfaces e endpoints';

  @override
  String get deviceInterfacesEndpointsSubtitle =>
      'Descritores de interface e endpoint analisados';

  @override
  String get deviceInputDeviceTitle => 'Dispositivo de entrada';

  @override
  String get deviceInputDeviceSubtitle =>
      'Informações de teclado/mouse do InputManager';

  @override
  String get deviceNameLabel => 'Name';

  @override
  String get deviceDescriptorLabel => 'Descritor';

  @override
  String get deviceExternalLabel => 'External';

  @override
  String get deviceSourcesLabel => 'Sources';

  @override
  String get deviceKeyboardTypeLabel => 'Keyboard type';

  @override
  String get deviceMotionRangesLabel => 'Motion ranges';

  @override
  String get deviceShowMotionRanges => 'Show motion ranges';

  @override
  String get deviceFrameworkLimitationsTitle =>
      'Limitações do framework Android';

  @override
  String get deviceFrameworkLimitationsSubtitle =>
      'O dispositivo está presente, mas o Android esconde parte dele ou não a expõe';

  @override
  String get devicePermissionDiagnosticsTitle => 'Diagnóstico de permissões';

  @override
  String get devicePermissionDiagnosticsSubtitle =>
      'Manifest, tempo de execução, estado USB, comportamento do Android e última falha';

  @override
  String get deviceLoadingDiagnostics => 'Carregando diagnóstico…';

  @override
  String get deviceShowPermissionDiagnostics => 'Show permission diagnostics';

  @override
  String get devicePermissionStateTemporary => 'Temporário';

  @override
  String get devicePermissionStatePermanent => 'Permanente';

  @override
  String get devicePermissionStateReenumerated => 'Reenumerado';

  @override
  String get devicePermissionStateNotInApp => 'Não disponível no app';

  @override
  String get devicePermissionStateRevoked => 'Revogado';

  @override
  String get deviceAndroidVersionLabel => 'Android version';

  @override
  String get deviceUsbDetailLabel => 'USB detail';

  @override
  String get deviceMicrophoneManifestLabel => 'Microphone manifest';

  @override
  String get deviceMicrophoneRuntimeLabel => 'Microphone runtime';

  @override
  String get deviceCameraManifestLabel => 'Camera manifest';

  @override
  String get deviceCameraRuntimeLabel => 'Camera runtime';

  @override
  String get deviceAndroidBehaviorLabel => 'Android behavior';

  @override
  String get deviceLastFailureReasonLabel => 'Last failure reason';

  @override
  String get deviceNoneRecorded => 'None recorded';

  @override
  String get deviceLastFailureDetailLabel => 'Last failure detail';

  @override
  String get deviceLastFailureTimeLabel => 'Last failure time';

  @override
  String get deviceWhyDataUnavailableTitle => 'Why data is unavailable';

  @override
  String get deviceWhyDataUnavailableSubtitle =>
      'Limitação exata do Android ou do dispositivo para campos ocultos';

  @override
  String get deviceReconnectDiffTitle => 'Diferença após reconexão';

  @override
  String get deviceReconnectDiffSubtitle =>
      'Dispositivo atual comparado com o estado capturado anteriormente';

  @override
  String get deviceStateTitle => 'Estado do dispositivo';

  @override
  String get deviceStateSubtitle =>
      'Configuração ativa, bits de estado e configurações alternativas';

  @override
  String get deviceActiveConfigurationLabel => 'Active configuration';

  @override
  String get deviceStatusLabel => 'Device status';

  @override
  String get deviceSelfPoweredLabel => 'Self-powered';

  @override
  String get deviceRemoteWakeupLabel => 'Remote wakeup';

  @override
  String get deviceInterfaceAlternateSettingsTitle =>
      'Configurações alternativas da interface';

  @override
  String get deviceStringDescriptorsTitle => 'Descritores de cadeia';

  @override
  String get deviceStringDescriptorsSubtitle =>
      'Idiomas e iManufacturer/iProduct/iSerial + iInterface';

  @override
  String get deviceLanguagesLabel => 'Languages';

  @override
  String get devicePreferredLabel => 'Preferred';

  @override
  String get deviceDeviceStringsTitle => 'Device strings';

  @override
  String get deviceManufacturerLabel => 'Manufacturer';

  @override
  String get deviceInterfaceStringsTitle => 'Strings da interface';

  @override
  String get deviceDescriptorTreeTitle => 'Árvore de descritores';

  @override
  String get deviceShowDescriptors => 'Mostrar descritores';

  @override
  String get deviceHidReportDescriptorsTitle => 'Descritores de relatório HID';

  @override
  String get devicePermissionRequiredTitle => 'Permissão necessária';

  @override
  String get devicePermissionRequiredBody =>
      'Para ler cadeias (fornecedor/produto/número de série), analisar descritores brutos e obter descritores de relatórios HID, o Android exige uma permissão por dispositivo.';

  @override
  String get deviceCameraPermissionRequiredForUsbVideo =>
      'Camera permission is required for USB video devices on this Android version.';

  @override
  String get devicePermissionNotGranted => 'Permissão não concedida';

  @override
  String get deviceGrantPermission => 'Conceder permissão';

  @override
  String get deviceAdvancedRawViewTitle => 'Visualização bruta avançada';

  @override
  String get deviceDescriptorNodesLabel => 'Nós do descritor';

  @override
  String get deviceControlTransfersLabel => 'Transferências de controle';

  @override
  String get deviceHidReportDumpsLabel => 'Dumps de relatórios HID';

  @override
  String get deviceControlTransfersTitle => 'Transferências de controle';

  @override
  String get deviceControlTransfersSubtitle =>
      'Raw setup/result records from direct USB control reads';

  @override
  String get deviceDescriptorsSideBySideTitle => 'Descritores lado a lado';

  @override
  String get deviceDescriptorsSideBySideSubtitle =>
      'Campos analisados ao lado dos bytes brutos do descritor';

  @override
  String get deviceHidReportDumpsTitle => 'Dumps de relatórios HID';

  @override
  String get deviceHidReportDumpsSubtitle =>
      'Hex do descritor de relatório com resumo analisado';

  @override
  String get deviceAdvancedDataUnavailableTitle => 'Advanced data unavailable';

  @override
  String get deviceAdvancedDataUnavailableSubtitle =>
      'Não há dados brutos de transferências de controle nem descritores disponíveis para este dispositivo.';

  @override
  String get deviceGrantPermissionReconnectNote =>
      'Grant USB permission and reconnect the device if you want Android to expose direct descriptor and transfer data.';

  @override
  String get deviceExportFormatJson => 'Carga JSON';

  @override
  String get deviceExportFormatReport => 'Relatório em texto simples';

  @override
  String get deviceExportFormatRawHex => 'Descritores hex brutos';

  @override
  String get deviceRawDumpExportTitle => 'Exportação de dump bruto';

  @override
  String get deviceRawDumpExportSubtitle =>
      'Exporte este instantâneo ao vivo diretamente sem usar o histórico.';

  @override
  String get deviceExportChipJson => 'JSON';

  @override
  String get deviceExportChipReport => 'Relatório';

  @override
  String get deviceExportChipRawHex => 'Hex bruto';

  @override
  String get deviceCopyAction => 'Copiar';

  @override
  String get deviceYes => 'Yes';

  @override
  String get deviceNo => 'No';

  @override
  String get deviceUsbPermissionLabel => 'USB permission';

  @override
  String get deviceMaxPowerShortLabel => 'Max power';

  @override
  String get devicePreviousCaptureLabel => 'the previous capture';

  @override
  String get deviceManifestStatusDeclared => 'Declared';

  @override
  String get deviceManifestStatusMissing => 'Missing';

  @override
  String get deviceRuntimeStatusGranted => 'Granted';

  @override
  String get deviceRuntimeStatusTemporarilyDenied => 'Temporarily denied';

  @override
  String get deviceRuntimeStatusPermanentlyDenied => 'Permanently denied';

  @override
  String get deviceRuntimeStatusNotRequired =>
      'Not required on this Android version';

  @override
  String get deviceIdentityConfidenceHigh => 'High';

  @override
  String get deviceIdentityConfidenceMedium => 'Medium';

  @override
  String get deviceIdentityConfidenceLow => 'Low';

  @override
  String get deviceIdentityStrategySerialNumber => 'Serial number';

  @override
  String get deviceIdentityStrategyPhysicalPort =>
      'Physical port + interface fingerprint';

  @override
  String get deviceIdentityStrategyInterfaceFingerprint =>
      'Impressão digital da interface';

  @override
  String get deviceIdentityStrategyModelFingerprint => 'Model fingerprint';

  @override
  String get historyDetailTitle => 'Detalhe do histórico';

  @override
  String get historyOpenLiveDeviceInfo =>
      'Abrir informações do dispositivo ao vivo';

  @override
  String get historyIdentitySubtitle => 'IDs e cadeias de fornecedor/produto';

  @override
  String get historyAdvancedDetailsNotCapturedTitle =>
      'Detalhes avançados não capturados';

  @override
  String get historyAdvancedDetailsNotCapturedBody =>
      'Esta entrada do histórico não inclui descritores brutos, cadeias nem relatórios HID. Esses campos exigem permissão USB no momento da captura.';

  @override
  String get historyRawDumpExportSubtitle =>
      'Exporte este instantâneo histórico diretamente a partir do histórico.';

  @override
  String deviceDescriptorsCount(int count) {
    return '$count descritor(es)';
  }

  @override
  String deviceReenumeratedAcrossPaths(int count) {
    return 'Re-enumerated across $count known path(s)';
  }

  @override
  String deviceAndroidVersionValue(Object sdk, Object release) {
    return 'SDK $sdk ($release)';
  }

  @override
  String deviceChangesDetectedCompared(int count, Object baseline) {
    return '$count change(s) detected compared with $baseline.';
  }

  @override
  String deviceShowingFirstRanges(int count) {
    return 'Showing first $count ranges.';
  }

  @override
  String deviceFrameworkLimitationsDetected(int count) {
    return '$count framework-related limitation(s) detected for this device.';
  }

  @override
  String deviceShowPermissionDiagnosticsWithUnavailableData(int count) {
    return 'Show permission diagnostics & unavailable data ($count)';
  }

  @override
  String deviceNoDifferencesDetected(Object baseline) {
    return 'No differences detected compared with $baseline.';
  }

  @override
  String deviceAltSettingValue(Object value) {
    return 'Alt $value';
  }

  @override
  String deviceShowingFirstInterfaces(int count) {
    return 'Showing first $count interfaces.';
  }

  @override
  String deviceShowingFirstInterfaceStrings(int count) {
    return 'Showing first $count interface strings.';
  }

  @override
  String deviceDescriptorsParsed(int count) {
    return '$count descritores analisados';
  }

  @override
  String deviceInterfacesCount(int count) {
    return '$count interface(s)';
  }

  @override
  String deviceCopiedToClipboard(Object title) {
    return '$title copied to clipboard.';
  }

  @override
  String deviceCaptureFrom(Object date, Object time) {
    return 'the capture from $date $time';
  }

  @override
  String get deviceInputSourcesLabel => 'Input sources';

  @override
  String deviceShowingFirstFields(int count) {
    return 'Mostrando apenas os primeiros $count campos.';
  }

  @override
  String deviceShowingFirstDescriptors(int count) {
    return 'Mostrando os primeiros $count descritores.';
  }

  @override
  String get settingsUsbBehaviorTitle => 'Comportamento USB';

  @override
  String get settingsUsbBehaviorSubtitle =>
      'Controla os avisos do sistema quando um dispositivo USB é conectado';

  @override
  String get settingsUsbOfferOnAttachTitle =>
      'Oferecer abertura ao conectar USB';

  @override
  String get settingsUsbOfferOnAttachSubtitle =>
      'Aparece no seletor do Android quando um dispositivo USB é conectado.';

  @override
  String get settingsUsbDisableAttachNote =>
      'Desative isso para impedir que o Android sugira o USBDevInfo ao conectar um dispositivo. O app continuará detectando dispositivos enquanto estiver aberto.';

  @override
  String get settingsAttachFilterScopeLabel => 'Escopo do filtro de conexão';

  @override
  String get settingsAttachFilterScopeAllUsbDevices =>
      'Todos os dispositivos USB';

  @override
  String get settingsAttachLaunchBehaviorLabel => 'Comportamento ao conectar';

  @override
  String get settingsAttachLaunchBehaviorEnabled =>
      'Abrir apenas quando o Android iniciar explicitamente o USBDevInfo pelo seletor USB';

  @override
  String get settingsAttachLaunchBehaviorDisabled =>
      'Alias do seletor desativado';

  @override
  String get settingsWhileAppOpenLabel => 'Enquanto o app está aberto';

  @override
  String get settingsWhileAppOpenValue =>
      'Eventos de conexão/desconexão USB atualizam os dados do dispositivo sem forçar navegação';

  @override
  String get settingsBackupDataTitle => 'Backup e dados';

  @override
  String get settingsBackupDataSubtitle =>
      'Exportar o histórico dos dispositivos em JSON';

  @override
  String get settingsHistoryLabel => 'Histórico';

  @override
  String get settingsMostRecentLabel => 'Mais recente';

  @override
  String get settingsNoHistoryYet => 'Ainda não há histórico';

  @override
  String settingsHistoryRecordedCount(int count) {
    return '$count item(ns) registrado(s)';
  }

  @override
  String get settingsBackupExportIncludes =>
      'A exportação inclui IDs de fabricante/produto, nomes resolvidos, strings, classe/protocolo, carimbos de data e hora e detalhes avançados (descritores, configurações, interfaces, relatórios HID) quando a permissão foi concedida.';

  @override
  String get settingsExportJsonAction => 'Exportar JSON';

  @override
  String get settingsImportJsonAction => 'Importar JSON';

  @override
  String get settingsUsbIdsDatabaseTitle => 'Banco de dados de IDs USB';

  @override
  String get settingsUsbIdsDatabaseSubtitle => 'Metadados e atualização';

  @override
  String deviceConfigurationTitle(Object id, Object suffix) {
    return 'Configuração $id$suffix';
  }

  @override
  String get deviceAttributesLabel => 'Atributos';

  @override
  String get deviceInterfacesSummaryTitle => 'Interfaces (resumo)';

  @override
  String deviceInterfaceShortLabel(Object id) {
    return 'IF $id';
  }

  @override
  String deviceInterfaceSummaryValue(Object classValue, Object endpointCount) {
    return 'Classe $classValue • EP $endpointCount';
  }

  @override
  String deviceInterfaceStringLabel(
    Object interfaceNumber,
    Object alternateSetting,
  ) {
    return 'IF $interfaceNumber (Alt $alternateSetting)';
  }

  @override
  String get deviceKeyboardChip => 'Teclado';

  @override
  String get deviceMouseChip => 'Mouse';

  @override
  String deviceReportIdsChip(Object count) {
    return 'IDs de relatório: $count';
  }

  @override
  String deviceCollectionsChip(Object count) {
    return 'Coleções: $count';
  }

  @override
  String deviceUsagePagesChip(Object pages) {
    return 'Páginas de uso: $pages';
  }

  @override
  String get homeCapabilityAudio => 'Áudio';

  @override
  String get homeCapabilityVideo => 'Vídeo';

  @override
  String get homeCapabilityHid => 'HID';

  @override
  String get homeCapabilityMidi => 'MIDI';

  @override
  String get homeCapabilityStorage => 'Armazenamento';

  @override
  String get homeCapabilityHub => 'Hub';

  @override
  String get homeCapabilityCdc => 'CDC';

  @override
  String get homeCapabilityComposite => 'Composto';

  @override
  String get homeCapabilityInput => 'Entrada';

  @override
  String get settingsUsbIdsLocalVersionLabel => 'Versão local';

  @override
  String get settingsUsbIdsLocalDateLabel => 'Data local';

  @override
  String get settingsUsbIdsRemoteShaNotFetched =>
      'O SHA remoto ainda não foi obtido.';

  @override
  String get settingsUsbIdsInstalledShaAfterUpdate =>
      'O SHA instalado será salvo após uma atualização bem-sucedida.';

  @override
  String get settingsUsbIdsInstalledShaMatchesRemote =>
      'O SHA instalado corresponde ao remoto.';

  @override
  String get settingsUsbIdsInstalledShaDiffersRemote =>
      'O SHA instalado difere do remoto (atualização disponível).';

  @override
  String get settingsUsbIdsDetailsTitle => 'Detalhes';

  @override
  String get settingsUsbIdsInstalledShaLabel => 'SHA-256 instalado';

  @override
  String get settingsUsbIdsRemoteShaLabel => 'SHA-256 remoto';

  @override
  String get settingsUsbIdsShaMatchLabel => 'Correspondência SHA';

  @override
  String get settingsUsbIdsLastCheckedLabel => 'Última verificação';

  @override
  String get settingsUsbIdsUpdateHintLabel => 'Indicação de atualização';

  @override
  String get settingsUsbIdsUpdateHintAvailable => 'Disponível';

  @override
  String get settingsUsbIdsUpdateHintNone => 'Nenhuma';

  @override
  String get settingsUsbIdsAutoCheckTitle =>
      'Verificar atualizações automaticamente';

  @override
  String get settingsUsbIdsAutoCheckSubtitle =>
      'Verifica o arquivo .sha256 remoto aproximadamente uma vez por semana.';

  @override
  String get settingsUpdateNow => 'Atualizar agora';

  @override
  String get settingsCheckNow => 'Verificar agora';

  @override
  String get settingsAboutSectionTitle => 'Sobre';

  @override
  String get settingsAboutSectionSubtitle => 'Informações do app e legais';

  @override
  String settingsAboutAppTileTitle(Object appName, Object developer) {
    return '$appName - $developer';
  }

  @override
  String settingsAboutVersion(Object version) {
    return 'Versão $version';
  }

  @override
  String get settingsLicensesTitle => 'Licenças';

  @override
  String get settingsLicensesSubtitle => 'Licenças de código aberto';

  @override
  String get settingsReportIssueTitle => 'Relatar problema';

  @override
  String get settingsReportIssueSubtitle => 'Erros e pedidos de recursos';

  @override
  String get settingsIssuesLinkCopied => 'Link de issues copiado';

  @override
  String get settingsNoHistoryToExport => 'Não há histórico para exportar.';

  @override
  String get settingsExportCopied =>
      'Exportação copiada para a área de transferência.';

  @override
  String settingsExportFailed(Object error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String get settingsImportUnsupportedFormat =>
      'Formato JSON não compatível. É esperado um array ou uma carga de exportação com schema=device_history_export_v1.';

  @override
  String get settingsImportNoValidHistoryEntries =>
      'Nenhuma entrada válida de histórico encontrada.';

  @override
  String settingsImportedItems(int count) {
    return '$count item(ns) importado(s).';
  }

  @override
  String settingsImportFailed(Object error) {
    return 'Falha ao importar: $error';
  }

  @override
  String get settingsClearHistoryBodyDetailed =>
      'Isso removerá todos os dispositivos registrados do armazenamento local.';

  @override
  String get settingsHistoryCleared => 'Histórico limpo.';

  @override
  String get settingsExportHistoryTitle => 'Exportar histórico';

  @override
  String settingsExportHistorySubtitle(int count) {
    return '$count item(ns) • JSON';
  }

  @override
  String get settingsExportFormatPretty => 'Formatado';

  @override
  String get settingsExportFormatCompact => 'Compacto';

  @override
  String get settingsExportSafeShareNote =>
      'Esta exportação é segura para compartilhar em depuração, mas pode conter nomes/caminhos de dispositivos e números de série.';

  @override
  String get settingsImportHistoryTitle => 'Importar histórico';

  @override
  String get settingsImportHistorySubtitle =>
      'Cole uma carga exportada ou uma lista bruta de entradas';

  @override
  String get settingsImportSupportedFormats =>
      'Formatos compatíveis: carga device_history_export_v1 (recomendado) ou um array JSON bruto de mapas de histórico.';

  @override
  String get settingsImportHint => 'Cole o JSON aqui…';

  @override
  String get settingsImportAction => 'Importar';

  @override
  String get settingsImporting => 'Importando…';

  @override
  String get settingsImportReplacesHistoryNote =>
      'A importação substitui o histórico atual. Em caso de dúvida, exporte primeiro.';

  @override
  String get settingsClipboardEmpty => 'A área de transferência está vazia.';

  @override
  String get settingsPasteJsonFirst => 'Cole o JSON primeiro.';

  @override
  String get pasteAction => 'Colar';

  @override
  String get donationFocusCompatTitle => 'Compatibilidade e permissões';

  @override
  String get donationFocusCompatSubtitle =>
      'Particularidades de OEM, fluxos de permissão, casos extremos';

  @override
  String get donationFocusUsbIdsTitle => 'Atualizações do banco de IDs USB';

  @override
  String get donationFocusUsbIdsSubtitle =>
      'Parsing, atualização e confiabilidade';

  @override
  String get donationFocusUiTitle => 'Ajustes de UI/UX';

  @override
  String get donationFocusUiSubtitle => 'Clareza, velocidade, acessibilidade';

  @override
  String get donationFocusFeaturesTitle => 'Novos recursos';

  @override
  String get donationFocusFeaturesSubtitle => 'Filtros, exportações, insights';

  @override
  String donationShareHeader(Object appName) {
    return 'Apoie $appName - App de código aberto';
  }

  @override
  String donationShareFocusLine(Object title) {
    return 'Foco: $title';
  }

  @override
  String get donationShareChainBtc =>
      'Bitcoin (BTC) - envie apenas pela rede Bitcoin.';

  @override
  String get donationShareChainEth =>
      'Ethereum (ERC-20) - envie apenas pela mainnet do Ethereum.';

  @override
  String donationShareBtcAddress(Object address) {
    return 'Endereço BTC: $address';
  }

  @override
  String donationShareEthAddress(Object address) {
    return 'Endereço ETH: $address';
  }

  @override
  String donationShareRepo(Object url) {
    return 'Repositório: $url';
  }

  @override
  String get donationNoBrowserForLiberapay =>
      'Nenhum navegador disponível para abrir o Liberapay';

  @override
  String get donationFailedToOpenLiberapay =>
      'Não foi possível abrir o Liberapay no navegador';

  @override
  String donationErrorOpeningLiberapay(Object error) {
    return 'Erro ao abrir o Liberapay: $error';
  }

  @override
  String get donationThankYouTitle => 'Obrigado';

  @override
  String get donationThankYouBody =>
      'Seu apoio ajuda a manter este app gratuito, rápido e ativamente mantido. Obrigado por apoiar software de código aberto.';

  @override
  String get donationFocusTitle => 'Foco da doação';

  @override
  String get donationFocusSubtitle =>
      'Opcional. Ajuda a priorizar o que fazer depois.';

  @override
  String get donationGeneralSupportTitle => 'Apoio geral';

  @override
  String get donationGeneralSupportSubtitle => 'A melhor opção geral';

  @override
  String get donationSupportDevelopmentTitle => 'Apoiar o desenvolvimento';

  @override
  String get donationSupportDevelopmentSubtitle =>
      'Doação opcional para financiar manutenção e recursos';

  @override
  String get donationOptionsTitle => 'Opções de doação';

  @override
  String get donationOptionsSubtitle =>
      'Sua contribuição mantém esta ferramenta gratuita, cuidada e guiada pela comunidade';

  @override
  String get donationRecommendedBadge => 'Recomendado';

  @override
  String get donationLiberapayFlexibleSupport => 'Opções flexíveis de apoio';

  @override
  String get donationTraditionalPayments =>
      'Métodos de pagamento tradicionais (cartão, PayPal, banco)';

  @override
  String get donationRecurringOrOneTime =>
      'Apoio recorrente flexível ou contribuição única';

  @override
  String get donationTrustedByOpenSource =>
      'Confiado por desenvolvedores de código aberto';

  @override
  String get donationOpeningBrowser => 'Abrindo navegador...';

  @override
  String get donationViaLiberapay => 'Doar via Liberapay';

  @override
  String get donationLiberapayNote =>
      'O Liberapay é uma plataforma de doações sem fins lucrativos em que projetos de código aberto confiam.';

  @override
  String get donationCryptoSupportTitle => 'Apoio direto com criptomoedas';

  @override
  String get donationCryptoSupportSubtitle =>
      'Opção focada em privacidade • Escaneie o QR ou copie o endereço';

  @override
  String get donationBtcShort => 'BTC';

  @override
  String get donationEthShort => 'ETH';

  @override
  String get donationGeneralShort => 'Geral';

  @override
  String get donationBitcoinNetworkOnly => 'Somente rede Bitcoin';

  @override
  String get donationEthereumNetworkOnly => 'Somente mainnet Ethereum';

  @override
  String get donationBitcoinTitle => 'Doação em Bitcoin';

  @override
  String get donationEthereumTitle => 'Doação em Ethereum';

  @override
  String get donationQrUnavailable => 'Código QR indisponível';

  @override
  String get donationAddressTitle => 'Endereço';

  @override
  String get donationBtcAddressCopied => 'Endereço BTC copiado';

  @override
  String get donationEthAddressCopied => 'Endereço ETH copiado';

  @override
  String get donationShareTextCopied => 'Texto de compartilhamento copiado';

  @override
  String get donationCopyAddress => 'Copiar endereço';

  @override
  String get donationShareAction => 'Compartilhar';

  @override
  String get donationSentAction => 'Já enviei uma doação';

  @override
  String get donationSecurityNote =>
      'Nota de segurança: nunca confie em endereços de doação vistos em capturas de tela, avaliações ou páginas de terceiros. Use apenas esta tela interna do app.';

  @override
  String deviceInterfaceTitle(Object id, Object classInfo) {
    return 'Interface $id • $classInfo';
  }

  @override
  String get deviceAltSettingLabel => 'Configuração alt';

  @override
  String get deviceClassLabel => 'Classe';

  @override
  String deviceEndpointsTitle(int count) {
    return 'Endpoints ($count)';
  }

  @override
  String get deviceNoEndpoints => 'Sem endpoints';

  @override
  String deviceEndpointAddressSummary(
    Object address,
    Object number,
    Object attributes,
  ) {
    return 'End. $address • EP nº $number • Atrib. $attributes';
  }

  @override
  String deviceEndpointMaxPacket(Object value) {
    return 'MaxPkt $value';
  }

  @override
  String deviceEndpointInterval(Object value) {
    return 'Intervalo $value';
  }

  @override
  String get deviceControlTransferDefaultTitle => 'Transferência de controle';

  @override
  String get deviceRequestedLengthLabel => 'Comprimento solicitado';

  @override
  String get deviceActualLengthLabel => 'Comprimento real';

  @override
  String get deviceResultLabel => 'Resultado';

  @override
  String get deviceTransferSuccess => 'Sucesso';

  @override
  String get deviceTransferFailed => 'Falhou';

  @override
  String get deviceResponseBytesHexTitle => 'Bytes de resposta (hex)';

  @override
  String get deviceParsedFieldsTitle => 'Campos analisados';

  @override
  String get deviceNoParsedFieldsAvailable =>
      'Não há campos analisados disponíveis.';

  @override
  String get deviceRawBytesTitle => 'Bytes brutos';

  @override
  String deviceInterfaceReportTitle(
    Object interfaceNumber,
    Object reportLength,
  ) {
    return 'Interface $interfaceNumber • Relatório de $reportLength bytes';
  }

  @override
  String get deviceParsedSummaryTitle => 'Resumo analisado';

  @override
  String get deviceNoParsedHidSummaryAvailable =>
      'Não há resumo HID analisado disponível.';

  @override
  String get deviceReportHexTitle => 'Hex do relatório';

  @override
  String get historyEntryNotFoundTitle => 'Entrada não encontrada';

  @override
  String get historyEntryNotFoundBody =>
      'Este item do histórico não existe mais.';

  @override
  String get historyUnableToOpenDetail =>
      'Não foi possível abrir o detalhe do histórico.';
}
