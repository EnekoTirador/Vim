" ── plugins/git.vim ── git dentro de Vim ───────────────────────────────────────
Plug 'mhinz/vim-signify'       " barras de cambios en el margen (+ ]c [c entre hunks)
Plug 'tpope/vim-fugitive'      " :Git, :Gdiffsplit, :Git blame ...

let g:signify_sign_add               = '▎'
let g:signify_sign_change            = '▎'
let g:signify_sign_delete            = '▁'
let g:signify_sign_delete_first_line = '▔'
let g:signify_sign_change_delete     = '▎'

call my#keys#map('n', '<leader>gs', '<Cmd>Git<CR>', 'Estado (fugitive)')
call my#keys#map('n', '<leader>gb', '<Cmd>Git blame<CR>', 'Blame de la línea / archivo')
call my#keys#map('n', '<leader>gd', '<Cmd>Gdiffsplit<CR>', 'Diff del archivo vs índice')
call my#keys#map('n', '<leader>gl', '<Cmd>Commits<CR>', 'Historial de commits (fzf)')
call my#keys#map('n', '<leader>gL', '<Cmd>BCommits<CR>', 'Historial de este archivo (fzf)')
call my#keys#map('n', '<leader>gh', '<Cmd>SignifyHunkDiff<CR>', 'Ver el cambio de este hunk')
call my#keys#map('n', '<leader>gu', '<Cmd>SignifyHunkUndo<CR>', 'Deshacer este hunk')
if executable('lazygit')
  call my#keys#map('n', '<leader>gg', '<Cmd>call my#run#lazygit()<CR>', 'lazygit a pantalla completa')
endif
