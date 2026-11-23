# Ekta NexCus Website

A responsive, static website for Ekta NexCus. Built with plain HTML, CSS and JavaScript so it can be hosted free on GitHub Pages.

## Files
- `index.html` — all page content and navigation
- `assets/style.css` — responsive design and styling
- `assets/script.js` — mobile navigation and current year

## Included sections
- Vision, the opportunity gap and the Suvidha platform concept
- Worker and employer pathways, including agriculture and unorganised work
- Mentorship, small-business support and research programmes
- Proposed social-impact and revenue model
- YouTube featured video and channel link (`@ektanexcus`)
- Intended alignment with selected UN Sustainable Development Goals
- Future-of-work research conversation and contact details

## Preview locally
1. Download and unzip the project.
2. Open `index.html` in Chrome, Edge or Firefox.
3. For a local server (optional), open a terminal in this folder and run:
   - Python: `python -m http.server 8000`
   - Then visit `http://localhost:8000`

## Publish with GitHub Pages
1. Create a GitHub repository named `ekta-nexcus-website` (or use your existing website repository).
2. Upload `index.html`, the `assets` folder and `README.md` to the repository root.
3. Open **Settings → Pages**.
4. Under **Build and deployment**, choose **Deploy from a branch**.
5. Choose branch `main` and folder `/ (root)`, then Save.
6. Wait for GitHub Pages to publish and open the URL shown on the Pages screen.

## Connect your custom domain
After the GitHub Pages URL works, add `www.vmahesh.in` under **Settings → Pages → Custom domain**. Then configure the DNS records at your domain provider exactly as GitHub Pages instructs. Do not remove existing DNS records until you have confirmed the new records and HTTPS are working.

## Important before launch
- Confirm that the Google Forms linked in the page are still active and collect the intended information.
- The YouTube embed uses video ID `hO1VENoOvE0`; confirm that the video is public and embedding is enabled. The channel link is `https://www.youtube.com/@ektanexcus`.
- SDG references describe intended alignment, not UN endorsement, certification or verified impact. Publish measured outcomes only when evidence is available.
- Revenue streams and the Suvidha concept are proposed model pathways; do not present them as launched services until operational.
- The support section intentionally uses email contact because no verified contribution/payment URL was supplied. Add a verified contribution link only after confirming the payment recipient, legal status and receipt process.
- Replace the sample upcoming-events message with confirmed dates, venues and registration links when available.
- Add a privacy notice explaining what personal data is collected, why it is collected, who can access it and how visitors can request correction/deletion. Link it beside the forms before collecting sensitive or extensive worker information.
- This is a static front-end. It does not yet provide user accounts, a private admin dashboard, a database, automated job matching or payment processing.

## Update the content
Open `index.html` in a text editor and search for the section heading or text you want to change. The Google Form links appear in the `href` attributes of the relevant buttons/cards.
