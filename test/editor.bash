#!/bin/bash

cat $1 > editor-input
if [ "`type -t mock_editor_filter`" = 'function' ]; then
  mock_editor_filter $1
fi
cat $1 > editor-output
