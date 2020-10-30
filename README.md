# Boondmanager Candidate Workflow

## Synopis
Boond WF is a single web page, to ease the transformation of emails sent by Job boards applications  into a Boond Managers Candidate.

On the left side of the screen you can browse through your GMails.

On the right side, you can edit the Boond's candidate to be created.

The bottom part of each side contains the action button.

Read here for detailed documentation : https://github.com/patrouil/boond_wf/wiki/00---Home

## Usage
- From your web browser, open the boond_wf URL.
- In the GMail action bar, at the bottom, connect to your Mail box.
A Google login popup window will appear.
- In the Boond action bar, at the bottom, connect to you Boond Manager workspace.
A Boond login popup window will appear.

In the mail list select an email.
With the trash button in the action bar you can delete useless messages.

If you drag a message from the message list into the Candidate form, an existing Candidate with the same email address will be searched into Boond mamager.

If the message seems to be a valid application, you can press the Application button. This is the leaftmost button of the GMail actions bar.

To convert an email into a Candidate, the web site does the following operations : 
- Searching for an existing Candidate with the same email address.
- Trying to guess the candidate lastname from his email address.
- A Boond Action related to this candidate is being created. This action holds the email's text, and it's attachments.

The save botton on the left side of the action barr, is used to save the Candidate, and the related action.
The view Candidate action opens a Boondmanager web page, to access to this Candidate.

## Demo
For a demo use this website : https://boond-wf.adjp.dev/

Use your own Boond Manager login/password to access to your workspace.
This website only records your IP address.
Settings and user login are recorded locally in your Browser.

## Installation
## google setup.
Before using this web page, you must setup an ID Client Auth for your website.
On your Google Could Platform select API and Services / Identifier.
Create an ID Client Identifier with these parameters : 
- Application type : Web.
- Name : Boond Candidate workflow (_could be any name_)
- Then enter the URI on your website.
Record the Client ID key ans the Client secret key.

Copy the keys values in a file assets/cfg/settings.json 
You are now able to connect to your Google Mailbox.
## Boondmanager setup
Connect to your Boond Manager with an admin user.
* Go to "Administration / Espace Developpeur" and the select "API/Sandbox".

Note the Client Key and the Client token.
These keys are not mandatory but are handful to enable Boond's automatic authentication.

In the Setting menu of the Web application, choose you Boond Manager settings : 
- Choose if you are using the Sandbox or the Production site.
- Give the Client Key and Client token to enable auto login feature.

* Go to "Administration / Compte administrateur"

Then in the "Autorisations et alertes" section enable  BasicAuth authentication.

## Disclaimer/Licenses
This work is licensed under the 
Creative Commons Attribution-ShareAlike 4.0 International License.

To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
## Acknowledgments.

This web app is written in [Flutter](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

I would like to thank [Didier Boelens](https://www.didierboelens.com/fr/blog/) for his Blog. Many articles are very handful to understand Flutter's internal behavior.

Boondmanager name and Boondmanager logo are trademarks of [Wish SAS](https://www.boondmanager.com/mentions-legales/) 

