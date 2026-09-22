#!/usr/bin/env python3
"""Talk to Alexander's client portal from your own repo. Standard library only (urllib).

Usage (run from your repo root):
  python3 .claude/skills/ai-consulting/scripts/aic_portal.py setup <token>      write AIC_PORTAL_TOKEN to .env
  python3 .claude/skills/ai-consulting/scripts/aic_portal.py status             check token + connection
  python3 .claude/skills/ai-consulting/scripts/aic_portal.py pull [--refresh]   write context/ai-consulting/*.md
  python3 .claude/skills/ai-consulting/scripts/aic_portal.py done <recId> [...] mark action item(s) done in the portal
  python3 .claude/skills/ai-consulting/scripts/aic_portal.py log "<text>"       send a note to Alexander (lands in his Requests inbox)
  python3 .claude/skills/ai-consulting/scripts/aic_portal.py paste <file|->     file a pasted transcript as the latest call (no token needed)

Config: AIC_PORTAL_TOKEN (required except for paste) and AIC_PORTAL_URL (optional) from .env or the environment.
Contract: .claude/skills/ai-consulting/references/api-contract.md
"""
import sys, os, json, re, datetime, urllib.request, urllib.error, urllib.parse

DEFAULT_URL = 'https://alexander-clients.vercel.app'
OUT = os.path.join('context', 'ai-consulting')
STATE = os.path.join(OUT, '.state.json')
RAW = os.path.join(OUT, 'context.json')
UA = 'aic-client-skill/1.0'
SINCE_MARGIN_MIN = 5   # server clocks drift; always re-ask for the last few minutes


def load_env():
    env = {}
    if os.path.exists('.env'):
        for line in open('.env', encoding='utf-8'):
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                k, v = line.split('=', 1)
                env[k.strip()] = v.split(' #')[0].strip().strip('"').strip("'")
    env.update({k: v for k, v in os.environ.items() if k.startswith('AIC_')})
    return env


def portal_url(env):
    return (env.get('AIC_PORTAL_URL') or DEFAULT_URL).rstrip('/')


def token_or_die(env):
    t = env.get('AIC_PORTAL_TOKEN', '')
    if not re.fullmatch(r'[A-Za-z0-9]{40}', t or ''):
        sys.exit('No valid AIC_PORTAL_TOKEN in .env. Ask Alexander for your portal token, then run: aic_portal.py setup <token>')
    return t


def call(env, method='GET', path='/api/context', body=None, query=None):
    url = portal_url(env) + path + (('?' + urllib.parse.urlencode(query)) if query else '')
    req = urllib.request.Request(url, method=method, headers={
        'Authorization': f'Bearer {token_or_die(env)}', 'Content-Type': 'application/json', 'User-Agent': UA},
        data=json.dumps(body).encode() if body is not None else None)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return json.loads(r.read() or b'{}')
    except urllib.error.HTTPError as e:
        txt = e.read().decode(errors='replace')[:300]
        hints = {401: 'token rejected: ask Alexander to re-issue it (or check .env)',
                 429: 'locked for 15 minutes after too many failed attempts',
                 404: 'that item is not yours or does not exist'}
        sys.exit(f'Portal returned {e.code}: {txt}\n{hints.get(e.code, "")}'.strip())
    except urllib.error.URLError as e:
        sys.exit(f'Cannot reach the portal at {portal_url(env)}: {e.reason}')


# ---------- .env ----------
def cmd_setup(args):
    if not args:
        sys.exit('usage: setup <token>')
    t = args[0].strip()
    if not re.fullmatch(r'[A-Za-z0-9]{40}', t):
        sys.exit('That does not look like a portal token (40 letters/digits). Copy it exactly as Alexander sent it.')
    lines = open('.env', encoding='utf-8').read().splitlines() if os.path.exists('.env') else []
    done = False
    for i, line in enumerate(lines):
        if re.match(r'^\s*AIC_PORTAL_TOKEN\s*=', line):
            lines[i] = f'AIC_PORTAL_TOKEN={t}'
            done = True
    if not done:
        lines += ['', '# --- Alexander\'s client portal (from /ai-consulting) ---', f'AIC_PORTAL_TOKEN={t}']
    open('.env', 'w', encoding='utf-8').write('\n'.join(lines).rstrip('\n') + '\n')
    gi = open('.gitignore', encoding='utf-8').read() if os.path.exists('.gitignore') else ''
    if not re.search(r'^\.env\s*$', gi, re.M):
        open('.gitignore', 'a', encoding='utf-8').write('\n.env\n')
        print('added .env to .gitignore')
    print(f'Saved AIC_PORTAL_TOKEN (ends with …{t[-4:]}) to .env')


def cmd_status(_):
    env = load_env()
    d = call(env, query={'section': 'items'})
    c = d['client']
    open_items = sum(1 for i in d.get('actionItems', []) if i['status'] == 'Open')
    print(f"Connected as {c['name']} ({c.get('company') or 'no company'}), phase {c.get('phase')}, {open_items} open action items. Portal: {portal_url(env)}")


# ---------- pull + markdown ----------
def md_escape(s):
    return str(s or '').replace('\r', '').strip()


def d10(s):
    return (s or '')[:10] or 'no date'


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w', encoding='utf-8').write(text.rstrip('\n') + '\n')


def render(d):
    c = d['client']
    stamp = f"<!-- generated by /ai-consulting from {portal_url(load_env())}/api/context at {d.get('generatedAt')} ; do not edit, re-run /ai-consulting instead -->"
    files = {}
    calls = d.get('calls') or []
    lines = [stamp, '# Latest call', '']
    if calls:
        k = calls[0]
        lines += [f"**{md_escape(k['title'])}** on {d10(k.get('date'))}" + (f" ({k['durationMin']} min)" if k.get('durationMin') else ''),
                  f"Recording: {k['recordingUrl']}" if k.get('recordingUrl') else '', f"Portal id: `{k['id']}`", '']
        for label, key in [('Summary', 'summary'), ('Takeaways', 'takeaways'), ('My action items (the client)', 'clientActionItems'),
                           ("Alexander's action items", 'myActionItems'), ('Builds discussed', 'buildsDiscussed'), ('My notes', 'clientNotes')]:
            if k.get(key):
                lines += [f'## {label}', md_escape(k[key]), '']
        if len(calls) > 1:
            lines += ['## Previous calls', '']
            for k in calls[1:8]:
                s = md_escape(k.get('summary'))
                lines.append(f"- {d10(k.get('date'))} **{md_escape(k['title'])}**: {(s[:220] + '…') if len(s) > 220 else s or 'no summary'}")
    else:
        lines.append('No calls in the portal yet.')
    files['latest-call.md'] = '\n'.join(lines)

    items = d.get('actionItems') or []
    lines = [stamp, '# Action items', '', 'Open items first. `id` is what `/ai-consulting done <id>` needs.', '']
    for status in ['Open', 'Done']:
        rows = [i for i in items if i['status'] == status]
        if status == 'Done':
            rows = rows[:25]
        lines += [f'## {status} ({len(rows)})', '', '| id | item | owner | due | source |', '|---|---|---|---|---|']
        for i in rows:
            lines.append(f"| `{i['id']}` | {md_escape(i['item'])} | {i.get('owner') or ''} | {d10(i.get('due')) if i.get('due') else ''} | {i.get('source') or ''} |")
        lines.append('')
    notes = [i for i in items if i.get('notes')]
    if notes:
        lines += ['## Notes on items', '']
        for i in notes[:30]:
            lines.append(f"- `{i['id']}` {md_escape(i['item'])}: {md_escape(i['notes'])}")
    files['action-items.md'] = '\n'.join(lines)

    road = d.get('roadmap') or []
    lines = [stamp, '# Roadmap', '', f"Program: {c.get('term') or '?'} months, {d10(c.get('startDate'))} to {d10(c.get('endDate'))}. Phase: {c.get('phase') or '?'}.", '',
             '| week | starts | theme | status | focus |', '|---|---|---|---|---|']
    for w in road:
        mark = '**Current**' if w.get('status') == 'Current' else (w.get('status') or '')
        lines.append(f"| {w.get('week')} | {d10(w.get('weekStart'))} | {md_escape(w.get('theme'))} | {mark} | {md_escape(w.get('focus')).replace(chr(10), ' ')} |")
    if not road:
        lines.append('| | | no roadmap yet | | |')
    files['roadmap.md'] = '\n'.join(lines)

    ob = d.get('onboarding')
    lines = [stamp, '# Onboarding answers', '', 'What I told Alexander at the start. Credentials are redacted on the server; the originals stay with him.', '']
    if ob:
        for section, qa in ob.items():
            lines += [f'## {section}', '']
            for q, a in qa.items():
                lines += [f'**{md_escape(q)}**', md_escape(a) or '(no answer)', '']
    else:
        lines.append('No onboarding submission yet.')
    files['onboarding.md'] = '\n'.join(lines)

    lines = [stamp, '# Builds, deliverables and resources', '']
    prds = d.get('prds') or []
    lines += [f'## Approved build specs ({len(prds)})', '']
    for p in prds:
        lines += [f"### {md_escape(p['title'])} ({p.get('priority') or ''}, {p.get('status')})", md_escape(p.get('body')) or '(no body)', '']
    dl = d.get('deliverables') or []
    lines += [f'## Delivered ({len(dl)})', '']
    for x in dl:
        lines.append(f"- **{md_escape(x['name'])}** ({x.get('type') or ''}, {x.get('status') or ''}){' ' + x['url'] if x.get('url') else ''}{': ' + md_escape(x['description'])[:200] if x.get('description') else ''}")
    if not dl:
        lines.append('- nothing delivered yet')
    res = d.get('resources') or []
    lines += ['', f'## Resources ({len(res)})', '']
    for r in res:
        lines.append(f"- [{md_escape(r['name'])}]({r.get('url') or ''}) ({r.get('type') or ''}){': ' + md_escape(r['description'])[:160] if r.get('description') else ''}")
    recaps = d.get('weeklyRecaps') or []
    if recaps:
        lines += ['', '## Weekly recaps', '']
        for r in recaps[:3]:
            lines += [f"### {md_escape(r['title'])} (week of {d10(r.get('weekOf'))})", md_escape(r.get('body')), '']
    files['builds.md'] = '\n'.join(lines)
    return files


def merge(old, new):
    """Merge a since-pull (only changed calls/items) into the cached full context."""
    for key in ['calls', 'actionItems']:
        by_id = {x['id']: x for x in (old.get(key) or [])}
        for x in new.get(key) or []:
            by_id[x['id']] = x
        new[key] = list(by_id.values())
    new['calls'].sort(key=lambda x: x.get('date') or '', reverse=True)
    new['actionItems'].sort(key=lambda x: (0 if x['status'] == 'Open' else 1, -(int(re.sub(r'\D', '', x.get('created') or '0') or 0))))
    for key in ['roadmap', 'prds', 'deliverables', 'onboarding', 'resources', 'weeklyRecaps']:
        if key not in new and key in old:
            new[key] = old[key]
    return new


def cmd_pull(args):
    env = load_env()
    query = {}
    state = json.load(open(STATE)) if os.path.exists(STATE) else {}
    refresh = '--refresh' in args and state.get('lastPull') and os.path.exists(RAW)
    if refresh:
        since = datetime.datetime.fromisoformat(state['lastPull'].replace('Z', '+00:00')) - datetime.timedelta(minutes=SINCE_MARGIN_MIN)
        query['since'] = since.strftime('%Y-%m-%dT%H:%M:%SZ')
    d = call(env, query=query)
    if refresh:
        d = merge(json.load(open(RAW)), d)
    files = render(d)
    for name, text in files.items():
        write(os.path.join(OUT, name), text)
    write(RAW, json.dumps(d, indent=1, ensure_ascii=False))
    write(STATE, json.dumps({'lastPull': d.get('generatedAt'), 'client': d['client'].get('name'), 'portal': portal_url(env)}))
    c = d['client']
    open_items = [i for i in d.get('actionItems', []) if i['status'] == 'Open']
    mine = [i for i in open_items if i.get('owner') == 'Client']
    print(f"Pulled context for {c['name']} ({c.get('phase') or 'no phase'}), {len(d.get('calls') or [])} calls, "
          f"{len(open_items)} open items ({len(mine)} mine), {len(d.get('roadmap') or [])} roadmap weeks, "
          f"{len(d.get('prds') or [])} approved specs, {len(d.get('deliverables') or [])} deliverables.")
    print('Wrote: ' + ', '.join(os.path.join(OUT, n) for n in files))


def cmd_done(args):
    if not args:
        sys.exit('usage: done <recId> [<recId> ...]')
    env = load_env()
    for rid in args:
        if not re.fullmatch(r'rec[A-Za-z0-9]{14}', rid):
            print(f'skip {rid}: not a portal id'); continue
        r = call(env, 'POST', body={'op': 'item-done', 'id': rid})
        print(f"done: {rid} -> {r.get('status')}")


def cmd_log(args):
    text = ' '.join(args).strip() if args else sys.stdin.read().strip()
    if not text:
        sys.exit('usage: log "<text>"')
    r = call(load_env(), 'POST', body={'op': 'log', 'text': text[:10000]})
    print(f"logged to Alexander's inbox ({r.get('id')})")


def cmd_paste(args):
    src = args[0] if args else '-'
    text = sys.stdin.read() if src == '-' else open(src, encoding='utf-8', errors='replace').read()
    text = text.strip()
    if len(text) < 40:
        sys.exit('Transcript looks empty. Paste the whole transcript, or give a file path.')
    today = datetime.date.today().isoformat()
    body = [f'<!-- pasted transcript filed by /ai-consulting paste on {today}; no portal token was used -->',
            '# Latest call (pasted transcript)', '', f'Filed: {today}. Source: pasted by me, not synced from the portal.',
            'Summary, takeaways and action items are extracted by the skill in the section below when it runs.', '',
            '## Extracted (fill in by running /ai-consulting apply)', '', '_pending_', '', '## Transcript', '', text]
    write(os.path.join(OUT, 'latest-call.md'), '\n'.join(body))
    ai = os.path.join(OUT, 'action-items.md')
    if not os.path.exists(ai):
        write(ai, '# Action items\n\nNo portal sync yet. Items extracted from pasted transcripts are listed here without ids; they cannot be marked done in the portal until a token is set up.\n\n## Open\n\n(none yet)\n')
    print(f'Filed transcript ({len(text)} chars) to {os.path.join(OUT, "latest-call.md")}')


if __name__ == '__main__':
    cmds = {'setup': cmd_setup, 'status': cmd_status, 'pull': cmd_pull, 'done': cmd_done, 'log': cmd_log, 'paste': cmd_paste}
    if len(sys.argv) < 2 or sys.argv[1] not in cmds:
        sys.exit(__doc__)
    cmds[sys.argv[1]](sys.argv[2:])
