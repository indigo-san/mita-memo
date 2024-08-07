'use client';

import type { Tables } from '@/types/supabase';
import {
  Button,
  FormControl,
  FormErrorMessage,
  FormLabel,
  Heading,
} from '@chakra-ui/react';
import Link from 'next/link';
import { useFormState } from 'react-dom';
import { AddRecord } from './postAction';
import { SubmitButton } from './submit-button';
import { UnwatchedAnimesList } from './unwatched-animes-list';

export function AddRecordForm({
  watchedItems,
}: { watchedItems: Tables<'animes'>[] }) {
  const [result, dispatch] = useFormState(AddRecord, {});

  return (
    <div className='mt-3 flex flex-col items-center'>
      <div className='flex-1 flex flex-col w-full px-4 sm:max-w-md justify-center gap-2'>
        <form
          action={dispatch}
          className='sm:p-4 sm:rounded-xl sm:border sm:border-slate-300'
        >
          <Heading className='mb-2' size='lg'>
            記録を追加
          </Heading>
          <FormControl isInvalid={result?.errors?.anime_id != null}>
            <FormLabel>記録する作品</FormLabel>
            <UnwatchedAnimesList watchedItems={watchedItems} />
            {result?.errors?.anime_id && (
              <FormErrorMessage>{result.errors.anime_id}</FormErrorMessage>
            )}
          </FormControl>
          <div className='flex mt-2 justify-between'>
            <SubmitButton pendingText='処理中...'>追加</SubmitButton>
            <Button variant='link' as={Link} href='/request'>
              リクエスト
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
