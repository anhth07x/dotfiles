"     .___________. __  ___                                 
"     |           ||  |/  /                                 
"     `---|  |----`|  '  /                                  
"         |  |     |    <                                   
"         |  |     |  .  \                                  
"         |__|     |__|\__\                                 
"       ______   ______   .__   __.  _______  __    _______ 
"      /      | /  __  \  |  \ |  | |   ____||  |  /  _____|
"     |  ,----'|  |  |  | |   \|  | |  |__   |  | |  |  __  
"     |  |     |  |  |  | |  . `  | |   __|  |  | |  | |_ | 
"     |  `----.|  `--'  | |  |\   | |  |     |  | |  |__| | 
"      \______| \______/  |__| \__| |__|     |__|  \______| 
"                                                           
"     
"     This is my personal configurations for vim, nvim.
"     You can customize it to solve your problems.

function! CopyPath(...)
  if a:1 == 'dir'
    let @+ = expand('%:p:h')
    echo "Copied dir path."
  elseif a:1 == 'project'
    if exists('g:working_dir')
      let @+ = g:working_dir
      echo "Copied project path"
    endif
  else
    let @+ = expand('%:p')
    echo "Copied file path."
  endif
endfunction

" Fugitive improvement

function! Get_Branch_Name(...)
  let branch_name = a:1
  silent exec ":Git checkout ".branch_name
  let current_branch = system('git branch --show-current')
  if current_branch != branch_name
    echohl ErrorMsg 
    echo "Please commit your changes or stash them before you switch branches."  
    echohl None
  else
    echo "You're in ".branch_name
  endif
endfunction

function! Git_Checkout_Branch()
    let s:current_file_path = expand('%:p:h')
    let s:current_project = system('git -C '. s:current_file_path . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
    if exists('s:current_project')
      call fzf#run(fzf#wrap({
      \'source': 'git -C ' . s:current_file_path .  ' branch -a --format "%(refname:short)" | sed -e "s/\w*\///g" | sort -u',  
      \'sink': function('Get_Branch_Name'),
      \'options': '--ansi --tiebreak=begin --prompt="  Branch >> "'}))
    else
      echohl WarningMsg
      echo "You're not in git project!"
      echohl None
    endif
endfunction

function! Git_New_Branch()
    call inputsave()
    let branch_name = input(" Branch's name: ")
    let standard_branch_name = substitute(branch_name, " ", "-", "g")
    silent exec ":Git branch ".standard_branch_name
    call inputrestore()
    silent exec ":Git checkout ".standard_branch_name
    redraw!
    echo "Created branch. Switch to ".standard_branch_name
endfunction

function! PastePath(...)
  let path = a:1
  let arr_part_1 = split(path, '/')
  let s:full_path = expand('%:p:h')
  let s:current_project = system('git -C '. s:full_path . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
  if exists('s:current_project')
    let s:relative_path = substitute(s:full_path, s:current_project, '', '')
  else
    let s:relative_path = s:full_path
  endif

  let arr_part_2 = split(s:relative_path, '/')
  if len(arr_part_1) > len(arr_part_2)
    let min = len(arr_part_2)
    let max = len(arr_part_1)
  else
    let min = len(arr_part_1)
    let max = len(arr_part_2)
  endif

  let count = 0
  while count < min
    if arr_part_1[count] != arr_part_2[count]
      :break
    endif
    let count += 1
  endwhile

  let count2 = count
  let result = './'
  while count2 < len(arr_part_2)
    let result = result . '../'
    let count2 += 1
  endwhile

  while count < len(arr_part_1)-1
    let result = result . arr_part_1[count].'/'
    let count += 1
  endwhile
  let result = result . arr_part_1[len(arr_part_1)-1]

  echo result
  let @" = result
  norm p
endfunction


function! Insert_Relative_Path()
  let s:full_path = expand('%:p:h')
  let s:current_project = system('git -C '. s:full_path . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
  if exists('s:current_project')
    let s:source_path = s:current_project
  else
    let s:source_path = s:full_path
  endif
  return fzf#run(fzf#wrap({
  \'source': 'rg --files --follow --hidden -g "!{node_modules,.git}" '.s:source_path. ' | sed "s:^"'.s:source_path.'/::',  
  \'sink': function('PastePath'),
  \'options': '--ansi --tiebreak=begin --prompt="  File >> "'}))
endfunction
