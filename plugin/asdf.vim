" asdf.vim - asdf support
" Maintainer:   jiz4oh <http://jiz4oh.com/>
" Version:      0.1

if exists('g:loaded_asdf') || v:version < 700 || &compatible || !executable('asdf')
  finish
endif
let g:loaded_asdf = 1

function! s:asdf_root()
  return empty($ASDF_DATA_DIR) ? expand('~/.asdf') : $ASDF_DATA_DIR
endfunction

function! s:ruby_version_paths() abort
  let dict = {}
  let root = s:asdf_root() . '/installs/ruby/'
  for entry in split(glob(root.'*'))
    let ver = entry[strlen(root) : -1]
    let paths = ver =~# '^1.[0-8]' ? ['.'] : []
    let paths += split($RUBYLIB, ':')
    let site_ruby_arch = glob(entry . '/lib/ruby/site_ruby/*.*/*-*')
    if empty(site_ruby_arch) || site_ruby_arch =~# "\n"
      continue
    endif
    let arch = fnamemodify(site_ruby_arch, ':t')
    let minor = fnamemodify(site_ruby_arch, ':h:t')
    let paths += [
          \ entry . '/lib/ruby/site_ruby/' . minor,
          \ entry . '/lib/ruby/site_ruby/' . minor . '/' . arch,
          \ entry . '/lib/ruby/site_ruby',
          \ entry . '/lib/ruby/vendor_ruby/' . minor,
          \ entry . '/lib/ruby/vendor_ruby/' . minor . '/' . arch,
          \ entry . '/lib/ruby/vendor_ruby',
          \ entry . '/lib/ruby/' . minor,
          \ entry . '/lib/ruby/' . minor . '/' . arch]
    let dict[ver] = paths
  endfor
  return dict
endfunction

if !exists('g:ruby_version_paths')
  let g:ruby_version_paths = {}
endif

function! s:set_paths() abort
  call extend(g:ruby_version_paths, s:ruby_version_paths(), 'keep')
  let ver = $ASDF_RUBY_VERSION

  if empty(ver)
    for line in readfile(fnamemodify('~/.tool-versions', ':p'))
      if line =~# 'ruby'
        let ver = matchstr(line, '\v\d+\.\d+\.\d+')
        break
      endif
    endfor
  endif

  if empty(ver)
    let ver = asdf_ruby#ruby_version('~')
  endif

  if has_key(g:ruby_version_paths, ver)
    let g:ruby_default_path = g:ruby_version_paths[ver]
  else
    unlet! g:ruby_default_path
  endif
endfunction

call s:set_paths()

" vim:set et sw=2:
