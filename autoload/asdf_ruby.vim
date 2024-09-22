function! asdf_ruby#ruby_version(dir)
  let dir = fnamemodify(a:dir, ':p')
  if !empty($ASDF_RUBY_VERSION)
    let ver = $ASDF_RUBY_VERSION
  else
    let stdout = system('cd ' . dir .' && asdf current ruby')
    if !empty(stdout) && v:shell_error == 0
      let ver = matchstr(stdout, '\v\d+\.\d+\.\d+')
    else
      return
    endif
  endif

  return ver
endfunction
