" ── config/terminal.vim ── terminal flotante, ejecutor de archivos y REPL ─────
" La mecánica está en autoload/my/float.vim y autoload/my/run.vim.
" Qué comando ejecuta cada lenguaje se define en config/languages.vim.
if !(has('terminal') && has('popupwin'))
  finish                      " Vim sin +terminal/+popupwin: no hay flotantes
endif

" Terminal flotante: F12 (o <Space>tt). Se oculta con F12; el shell sigue vivo.
call my#keys#map('n', '<F12>', '<Cmd>call my#run#terminal()<CR>', 'Terminal flotante (mostrar/ocultar)')
call my#keys#map('n', '<leader>tt', '<Cmd>call my#run#terminal()<CR>', 'Terminal flotante (mostrar/ocultar)')
call my#keys#map('t', '<F12>', '<Cmd>call my#float#hide_all()<CR>', 'Ocultar terminal flotante')
call my#keys#map('n', '<leader>tk', '<Cmd>call my#float#kill_all()<CR>', 'Matar todos los terminales flotantes')

" Ejecutar el archivo actual en el terminal flotante: F5 (o <Space>rr)
call my#keys#map('n', '<F5>', '<Cmd>call my#run#file()<CR>', 'Ejecutar este archivo')
call my#keys#map('n', '<leader>rr', '<Cmd>call my#run#file()<CR>', 'Ejecutar este archivo')
call my#keys#map('n', '<leader>ra', '<Cmd>call my#run#ask()<CR>', 'Ejecutar con argumentos...')
call my#keys#map('n', '<leader>rl', '<Cmd>call my#run#last()<CR>', 'Repetir la última ejecución')
call my#keys#map('n', '<leader>rp', '<Cmd>call my#run#repl()<CR>', 'REPL del lenguaje (mostrar/ocultar)')
call my#keys#map('n', '<leader>rs', '<Cmd>call my#run#send(line("."), line("."))<CR>', 'Enviar línea al REPL')
call my#keys#map('x', '<leader>rs', ':<C-u>call my#run#send(line("''<"), line("''>"))<CR>', 'Enviar selección al REPL')

command! -nargs=* Run call my#run#file(<q-args>)
command! Term call my#run#terminal()
command! Repl call my#run#repl()
command! Doctor call my#doctor#show()

augroup MyTerminal
  autocmd!
  autocmd VimResized * call my#float#reposition()
  " Sin esto, :qa se queja de "job still running" por los terminales ocultos
  autocmd QuitPre * if winnr('$') == 1 | call my#float#kill_all() | endif
augroup END
