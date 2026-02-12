# ~/.config/qutebrowser/config.py

config.load_autoconfig(False)

# --------------------------------------------------
# Browser UI dark theme (built-in, no files needed)
# --------------------------------------------------
c.colors.webpage.preferred_color_scheme = 'dark'

c.colors.completion.category.bg = '#1e1e1e'
c.colors.completion.category.border.bottom = '#1e1e1e'
c.colors.completion.category.border.top = '#1e1e1e'
c.colors.completion.category.fg = '#d4d4d4'

c.colors.completion.item.selected.bg = '#333333'
c.colors.completion.item.selected.fg = '#ffffff'
c.colors.completion.match.fg = '#569cd6'

c.colors.statusbar.normal.bg = '#1e1e1e'
c.colors.statusbar.normal.fg = '#d4d4d4'
c.colors.statusbar.command.bg = '#1e1e1e'
c.colors.statusbar.command.fg = '#ffffff'
c.colors.statusbar.insert.bg = '#005f5f'
c.colors.statusbar.insert.fg = '#ffffff'

c.colors.tabs.bar.bg = '#1e1e1e'
c.colors.tabs.even.bg = '#1e1e1e'
c.colors.tabs.odd.bg = '#1e1e1e'
c.colors.tabs.selected.even.bg = '#333333'
c.colors.tabs.selected.odd.bg = '#333333'
c.colors.tabs.selected.even.fg = '#ffffff'
c.colors.tabs.selected.odd.fg = '#ffffff'

# --------------------------------------------------
# Webpage dark mode (all websites)
# --------------------------------------------------
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.images = 'smart'
c.colors.webpage.darkmode.threshold.background = 128
c.colors.webpage.darkmode.threshold.text = 128

# Toggle dark mode
config.bind('<Ctrl-d>', 'config-cycle colors.webpage.darkmode.enabled true false')

# --------------------------------------------------
# Adblocking (Brave + EasyList)
# --------------------------------------------------
c.content.blocking.method = 'both'

c.content.blocking.adblock.lists = [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
    'https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-firstparty.txt',
    'https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-unbreak.txt',
    'https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-social.txt',
    'https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-trackers.txt',
]

# --------------------------------------------------
# Quality-of-life defaults
# --------------------------------------------------
c.content.autoplay = False
c.scrolling.smooth = True
c.tabs.show = 'multiple'

c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'ddg': 'https://duckduckgo.com/?q={}',
    'gh': 'https://github.com/search?q={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
}
