# Infrastructure as Code Intro - Setup (Azure OpenTofu Edition)

## 🎓 Compito / Assignment

**Obiettivo**: Eseguire l'ambiente di laboratorio su **Azure Container Apps** utilizzando **OpenTofu** (Infrastructure as Code).

1.  Segui la guida qui sotto per effettuare il deploy su Azure.
2.  Verifica che il server Minecraft sia accessibile tramite il dominio (o IP).
3.  Carica in questo repository gli **Screenshot** richiesti.

---

Questo repository contiene la configurazione **OpenTofu** per avviare un server Minecraft su Azure Container Apps, con supporto opzionale per Azure DNS.

## 1. Scaricare il Repository

Clona il repository:

```powershell
git clone <URL_DEL_TUO_REPOSITORY>
cd iac-intro
```
## 2. Prerequisiti

Una volta clonato il repository, esegui lo script di installazione per preparare il tuo computer con tutti i software necessari (OpenTofu, Azure CLI, ecc.):

```powershell
.\install.ps1
```
*   Accetta le richieste di amministrazione se compaiono.
*   Riavvia il terminale se richiesto.

Assicurati di avere installato:
*   **[OpenTofu](https://opentofu.org/docs/intro/install/)**
```powershell
tofu -v
```
*   **[Azure CLI](https://docs.microsoft.com/it-it/cli/azure/install-azure-cli)** 
```powershell
az version
```

Devi inoltre avere un [account Azure attivo](https://azure.microsoft.com/it-it/free/students).

## 3. Deploy su Azure (OpenTofu)

**Il Provider Azure: `az login`**
    OpenTofu (o Terraform) è solo un esecutore logico e non ha permessi intrinseci sul tuo cloud. Il provider `azurerm` dice *con chi* parlare, ma `az login` dice *chi sei*. Senza autenticazione, Tofu non può creare risorse per tuo conto. Esegui sempre `az login` prima di configurare tofu.


### Login su Azure
Per iniziare, autenticati con il tuo account Azure:

```powershell
az login
```

### Inizializzazione
Inizializza OpenTofu per scaricare i provider necessari:

```powershell
tofu init
```

### Configurazione Variabili
Copia il file di esempio delle variabili:

```powershell
cp terraform.tfvars.example terraform.tfvars
```

Modifica il file `terraform.tfvars` appena creato:

*   **Importante**: Assegna nomi **globalmente univoci** a:
    *   `storage_account_name`: deve essere unico in tutto Azure (es. `stminecraft[nome]`).
    *   `acr_name`: deve essere unico in tutto Azure (es. `acrminecraft[nome]`).
    *   *Suggerimento*: Aggiungi il tuo nome o numeri casuali alla fine (solo lettere minuscole e numeri).
*   (Opzionale) Imposta `domain_name` se possiedi un dominio personalizzato. Se lasciato vuoto o rimosso, verrà usato il dominio di default di Azure o l'IP statico.

### Pianificazione (Plan)

**Il "Plan" è la Vostra Sicurezza**
    Il comando `tofu plan` (o `terraform plan`) è la tua rete di salvataggio. Ti mostra esattamente cosa verrà creato, modificato o distrutto *prima* che accada. Leggilo sempre attentamente per evitare modifiche indesiderate o distruzioni accidentali.

Quindi è fondamentale verificare quello che tofu sta per fare prima di applicare le modifiche.

```powershell
tofu plan
```

Analizza l'output:
*   Controlla che vengano create le rigorse previste (es. `azurerm_container_app`, `azurerm_storage_account`).
*   Verifica che non ci siano distruzioni impreviste (`0 to destroy` è l'ideale per un nuovo deploy, ma attenzione agli aggiornamenti).

### Deploy (Apply)
Solo se il piano ti soddisfa, applica la configurazione per creare le risorse su Azure:

```powershell
tofu apply
```
Digita `yes` quando richiesto per confermare.

## 4. Accesso al Server

Al termine del deployment, OpenTofu mostrerà degli **Outputs** (puoi rivederli con `tofu output`).

*   **Indirizzo Minecraft**: Usa il valore di `connect_minecraft`.
    *   Es. `undominio.azure.com:25565` oppure `<IP_Statico1>:25565`.
*   **DNS**: Se hai configurato un dominio personalizzato, aggiorna i Nameserver del tuo registrar con quelli mostrati in `dns_name_servers`.

### Verifica
1.  Apri Minecraft.
2.  Aggiungi server con l'indirizzo ottenuto.
3.  Entra nel mondo!

## 5. Dimostrazione (Screenshots)

Su questo repository, carica screenshot che mostrano:
1.  Il terminale con l'output di `tofu apply` completato.
2.  Il server Minecraft nella lista server (con ping verde) o mentre sei in gioco.

## 6. Spegnimento (Pulizia)

Per non consumare credito e non pagare di più, rimuovere tutte le risorse create su Azure:

```powershell
tofu destroy
```
Digita `yes` per confermare.

⚠️ **Attenzione**: I dati del mondo (salvati su Azure Files) verranno mantenuti se la "Share" non viene distrutta, ma `tofu destroy` rimuove risorse come Storage Account se gestiti da Tofu. In questa configurazione, lo Storage Account è gestito da Tofu, quindi **verrà eliminato insieme ai dati**. Se vuoi preservarli, dovresti rimuovere lo State o usare un Lifecycle block, ma per questo lab, `tofu destroy` pulisce tutto.

---
## Licenza
Distribuito sotto licenza MIT.