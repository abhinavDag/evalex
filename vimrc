" log everytime a file is opened 
autocmd BufReadPost * call WriteFileOpening()

" log everytime a file is saved
autocmd BufWritePost * call WriteFileSaving()

" log the opening of a new buffer, not an existing file
autocmd VimEnter * call WriteNewBuffer()

" if the vim has exited, then delete the old_buffer_copy.txt
autocmd VimLeave * call RemoveOldBufferCopy()

function! RemoveOldBufferCopy()

  " check if it exists, then remove it
  if filereadable("/home/abhi/old_buffer_copy.txt")
    call delete("/home/abhi/old_buffer_copy.txt")
  endif

endfunction

function! WriteNewBuffer()

  " get the timestamp
  let timestamp = strftime("%Y-%m-%d %H:%M:%S")
  
  " if the buffer name is empty, then it means no existing file is being edited, so new buffer, then only write
  if empty(bufname(1))
    " writing to the log file
    call writefile([timestamp . " : " . "new buffer opened"], '/home/abhi/log.txt', 'a')
  endif

endfunction

function! WriteFileOpening()
  
  " get the timestamp
  let timestamp = strftime("%Y-%m-%d %H:%M:%S")
  
  " get the filename that has been opened to the buffer
  let filename = expand("<afile>")

  " writing to the log file
  call writefile([timestamp . " : " . filename .  " : " . "opened"], '/home/abhi/log.txt', 'a')

endfunction

function! WriteFileSaving()
 
  " get the timestamp
  let timestamp = strftime("%Y-%m-%d %H:%M:%S")
  
  " get the filename that has been opened to the buffer
  let filename = expand("<afile>")

  " writing to the log file
  call writefile([timestamp  . " : " . filename . " : " . "saved"], '/home/abhi/log.txt', 'a')

endfunction

function! WriteBufferLineCount(timer_id)

  " get the full buffer
  let buffer_copy = join(getbufline(1,1,"$"), "\n")

  " get the line count of buffer
  let line_count = len(buffer_copy)

  " get the old_buffer_copy, if exists
  if filereadable("/home/abhi/old_buffer_copy.txt")
    let old_buffer_copy_array = readfile("/home/abhi/old_buffer_copy.txt")
    let old_filename = remove(old_buffer_copy_array, 0)
    let old_buffer_copy = join(old_buffer_copy_array, "\n")
  else
    " else, to prevent issues, the old buffer copy will be the new one
    let old_buffer_copy = buffer_copy
  endif

  " get the old_line_count of old_buffer_copy
  let old_line_count = len(old_buffer_copy)

  " get the timestamp
  let timestamp = strftime("%Y-%m-%d %H:%M:%S")

  " get the filename of the file being edited
  let filename = bufname(1)
  
  " if the filename is empty, that means that it is a new standard buffer 
  if empty(filename)
    let filename = "std_buffer"
  endif
  
  " now, what we are trying to do is that, if the difference between buffer
  " lengths is uncanny, then store the before and after in a file, so that the
  " prof can see if the student really copied or not
  if( line_count-old_line_count > 15 )
    
    " now, this is a suspicious condition, so we have to log the buffers
    let to_write_sus = "\n" . timestamp . " : " . filename . " : " . old_line_count . " to " . line_count .  "\n=======================START BEFORE=======================\n" . old_buffer_copy . "\n========================END BEFORE======================== : " . old_line_count . "\n========================START AFTER=======================\n" . buffer_copy . "\n=========================END AFTER======================== : " . line_count . "\n" 
    call writefile(split(to_write_sus, "\n"), "/home/abhi/sus.txt", "a")
  endif

  " write the buffer to old_buffer_copy.txt
  let to_write_old_buffer_copy = filename . "\n" . buffer_copy
  call writefile(split(to_write_old_buffer_copy, "\n"), "/home/abhi/old_buffer_copy.txt", "w")
  

  " write it to a file, overwriting each time (or use append if you want)
  call writefile([timestamp  . " : " . filename . " : " . line_count], '/home/abhi/log.txt', 'a')

endfunction

" set a repeating timer every 1000 ms (1 sec)
let g:my_timer = timer_start(1000, 'WriteBufferLineCount', {'repeat': -1})

