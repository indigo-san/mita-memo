import type { Tables } from '@/types/supabase';
import createMetadata from '@/utils/createMetadata';
import { createClient } from '@/utils/supabase/server';
import type { PropsWithChildren } from 'react';

export default async function Layout({ children }: PropsWithChildren) {
  return <>{children}</>;
}

export async function generateMetadata({
  params: { id },
}: { params: { id: string } }) {
  const supabase = createClient();

  const { data, error } = await supabase
    .from('animes')
    .select()
    .eq('id', `${id}`)
    .returns<Tables<'animes'>[]>();

  return createMetadata(`'${data?.[0].name}' - Mita-memo`, `/animes/${id}`);
}
